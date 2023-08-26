---
title: "OPNsense, HAProxy and Organizr Auth"
date: 2023-08-26T14:00:00-04:00
description: "Simultaneously simpler and more complicated than it ought to be."
---

Sometimes, you post a rant on Mastodon at 3am that you end with "this should be a blog post".

{{<figure src="/images/opnsense-haproxy-organizr/this-should-be-a-blog-post.avif" alt="demize, 8 hours ago: anyway it's 3am and this rant should probably be a blog post so">}}

Well, this is that blog post.

{{< toc >}}

## Introduction

I recently switched back to running a *fancy* firewall on my home network. Well, fancier than the wifi router I'm now using as an access point, at least. It's running OPNsense, and I bought a new domain to use for my home network, and one of the main things I need to use that domain to expose publicly is Organizr. Organizr is a sort of aggregate control panel for what's commonly referred to as \*arr software; it works by embedding iframes for each piece of software you're managing, and because of this you need to have some sort of authentication solution if you want to expose it publicly (otherwise the software will be accessible to anybody who knows the URL of the iframe, and we don't want that). Thankfully Organizr provides a pretty useful mechanism for this that it calls "server authentication". You can read the [documentation](https://docs.organizr.app/features/server-authentication) for more details, but there are two methods it uses here, and they both share similar problems in our setup. We'll be discussing both, because I tried both, and it turns out that the configuration is basically the same in either case: you need to do a little bit of option pass-through, and you need to split the configuration between the frontend and the backend (while you wouldn't in a hand-written HAProxy config), but you're doing roughly the same things in the same places regardless of method.

If you haven't decided which method to use, I'd probably recommend the JWT method. It should have less overhead, and it doesn't require a Lua script.

## Setup outline

For both methods, our setup will be the same:

1. An option pass-through in the frontend ("public service" in the OPNsense GUI) to add in a couple `http-request` options we need executed before any of the backend rules.
2. One or more conditions in the backend to use the information generated/extracted by the `http-request` options in the frontend, also using option pass-through.
3. A rule for each of those conditions.
4. Those rules applied to each backend that needs to be protected by Organizr auth.

Overall it's not too complicated. It's not quite *ideal*, because we're splitting the logic between the front- and backends, but it's not really a problem.

## Why do we need to split the config anyway?

{{<figure src="/images/opnsense-haproxy-organizr/haproxy-warning.avif" alt="demize on Mastodon. First we see a quoted HAProxy warning, saying an http-request rule placed after a use_backend rule will still be processed before. Following the quote, demize says 'and thank god for that'." title="The post that started this post.">}}

This setup will, unfortunately, cause that warning. If we could do all the configuration in the frontend, or do all the configuration in the backend, we wouldn't get that warning! And (as these following minimal examples show) you *can* do the config like that:

{{<details summary="A basic example HAProxy config handling auth in the backend">}}
```
frontend https
    bind 0.0.0.0:443 name 0.0.0.0:443 ssl alpn h2,http/1.2
    mode http
    default_backend denied
    option forwardfor

    # A couple host matches
    acl organizr_host hdr -i organizr.example.org
    acl service_host hdr -i service.organizr.example.org

    # Usual backend stuff
    use_backend organizr if organizr_host
    use_backend service if service_host

backend organizr
    mode http
    server organizr 192.0.2.1:80

backend service
    mode http

    # Perform the auth request
    http-request lua.auth-request organizr /api/v2/auth/1

    # ACL for successful auth
    acl acl_organizr_auth_success var(txn.auth_response_successful) -m bool

    # Deny unsuccessful auth
    http-request deny if !acl_organizr_auth_success

    server service 192.0.2.2:80

backend denied
    mode http
    http-request deny
```
{{</details>}}

{{<details summary="A basic example HAProxy config handling auth in the frontend">}}
```
frontend https
    bind 0.0.0.0:443 name 0.0.0.0:443 ssl alpn h2,http/1.2 crt-list /wherever/this/is/generated/by/opnsense
    mode http
    default_backend denied
    option forwardfor

    # Perform the auth request
    http-request lua.auth-request organizr /api/v2/auth/1

    # ACL for successful auth
    acl acl_organizr_auth_success var(txn.auth_response_successful) -m bool

    # A couple host matches
    acl organizr_host hdr -i organizr.example.org
    acl service_host hdr -i service.organizr.example.org

    # ACL for successful auth
    http-request deny if !organizr_host !acl_organizr_auth_success

    # Usual backend stuff
    use_backend organizr if organizr_host
    use_backend service if service_host

backend organizr
    mode http
    server organizr 192.0.2.1:80

backend service
    mode http
    server service 192.0.2.2:80

backend denied
    mode http
    http-request deny
```
{{</details>}}

So why can't we do that through the OPNsense GUI?

Because the OPNsense GUI isn't designed for us, and it makes some decisions that (while they make sense for its goal of being user-friendly and abstracting away how HAProxy configuration works) make this impossible.

The OPNSense GUI gives us a fairly limited selection of options we can use, which (reasonably) does not include the options to use the `auth_request` Lua script we need in Option 1 or the various JWT functions we use in Option 2. And while it *does* provide the ability to pass through raw HAProxy configuration, this is also fairly limited: in the frontend and backend configuration, you can only pass through options after all the generated options, which would put the option to verify your authentication *after* the options that give you authentication information to verify. Option pass-through in conditions is also limited to only *part* of a line, which works very well for simple conditions, but unfortunately prevents us from gluing two lines together to make a single condition.

And while we *could* simply write fully custom logic within the frontend or backend option pass-through, I wanted something relatively idiomatic, something that's as unlikely as possible to break with an update. So you get what we've got here: using option pass-through only where necessary (or, for the frontend settings in Option 2, to avoid a bit of spaghetti), resulting in something we can still configure primarily through the standard options within the GUI. That is, while our rules depend on logic that's inserted through option pass-through, we're still using the rules *GUI*, and managing them--once they've been set up--is exactly the same as managing any other rule.

## Option 1: the `auth_request` (Organizr authentication API) method

This method uses nginx's `auth_request` function, or similar functions in other reverse proxy software, to authorize every request to the software it protects. This sends a request to Organizr on every web request, but works pretty well, and is typically pretty easy to configure...

...unless you're using the specific combination of OPNsense, OPNsense's built-in HAProxy, and the Organizr authentication API.

We've already covered why we have to split the configuration between the frontend and backend, but there's another problem:

### The Lua scripts

HAProxy doesn't have `auth_request` functionality by default, but there *is* a good Lua plugin that will handle it. We just need to install it. OPNsense does provide this functionality pretty easily, though we need to do some... optimization first.

[This reddit post](https://www.reddit.com/r/opnsense/comments/oyv6yp/howto_opnsense_haproxy_multilua/) ([archive.is link, just in case](https://archive.is/XSHss)) is a pretty good overview of how to solve the problem, though (since it's, as of writing, 2 years old) it gets the problem slightly wrong. Since that post, OPNsense has added the ability for you to save your Lua scripts with the name you give them! Unfortunately, it doesn't *actually* use the names you give your scripts. It strips out dashes and underscores. Now, this would be fine if we just needed to include one script, but we actually need to include three: `auth-request`, which can be named anything; `json`, which has no special characters in the name; and `haproxy-lua-http`, which has dashes in the name. HAProxy will strip those dashes out, making `auth-request` unable to include the script without modifications. The easiest modification is, as the Reddit post describes, simply to bundle the three scripts together.

If you have NPM installed, this is pretty easy to do with npx, assuming you have all the files in the same folder:

```bash
$ npx luabundler bundle auth-request.lua -p "./?.lua" -o auth-request-bundled.lua
```

Then you can just add the output file to HAProxy under the "Advanced" tab in OPNsense. Problem solved, onto the actual configuration!

#### Frontend settings

Caveat: This will check whether *every* request through your frontend is authorized, whether or not you care. If you're hosting other services that don't require authorization through Organizr, they will still request it, even if you don't use the result. If this is an issue, you can try the JWT method, which uses cookies instead.

{{<details summary="Another possible workaround (cursed)">}}

I haven't tried this. I don't think I want to try this. But if that's likely to be an issue for you and (for some reason) you don't want to use the JWT method, I think this will work: create a second frontend for your services, add it as a backend, and in your main frontend instruct HAProxy to use itself as a backend for requests to your services. You'll need to have all the conditions necessary for this anyway, so it won't be too much extra work.

But I don't know if it'll work. If it does, it's cursed. Proceed at your own risk.

{{</details>}}

With that out of the way, the frontend setup is pretty simple, even if it does result in the warning mentioned above. You'll want to go to the settings for your frontend ("Public Service") that serves your services, toggle on advanced mode in the top left, and enter in the option to run the auth request under "Option pass-through" in the advanced settings section near the bottom:

{{<figure src="/images/opnsense-haproxy-organizr/frontend-pass-through.avif" alt="A screenshot of the advanced settings section showing the below text in the option pass-through.">}}

Your option will be something like I entered there, depending on what you named your Organizr backend:

```
# Perform the auth request
http-request lua.auth-request organizr /api/v2/auth/1
```

That's it for the frontend! Well, for the auth request. You're on your own for the rest of the configuration 😛

#### Backend settings

As mentioned earlier, we'll still be relying on the built-in rule and condition management, even if we do need to do a little option pass-through here. First off, create a new condition to match on failed auth:

{{<figure src="/images/opnsense-haproxy-organizr/condition.avif" alt="A condition named '90_Organizr auth unsuccessful' with the condition type set to 'Custom condition', the 'Negate condition' option checked, and the pass-through set as per below.">}}

The option pass-through here has to be `var(txn.auth_response_successful) -m bool`. This will pull in the result of the auth request performed in the frontend. You may also want to create an additional rule to exempt the API from authentication, since the API handles its own authentication; you can do this with another negated rule matching the beginning of the path to `/api/`.

Next, create a rule to deny requests if the auth request was unsuccessful. In my case, this uses the two conditions just described: if the auth was unsuccessful and the path doesn't begin with `/api/` it will deny the request with `http-request deny`.

{{<figure src="/images/opnsense-haproxy-organizr/rule.avif" alt="That rule we just described.">}}

Finally, within each of your service backends, you need to select the new rule you just created.

And now you're done!

## Option 2: Javascript Web Token (JWT) method

Just like the other method, because we have to use option pass-through, we'll need to divide the settings here between the frontend and the backend. You could *probably* do this all in the backend by accessing things directly, rather than extracting fields like I am here; I based this on the four sample lines from the HAProxy documentation for [`jwt_verify`](https://cbonte.github.io/haproxy-dconv/2.5/configuration.html#7.3.1-jwt_verify), and I didn't try to optimize it. You'd need to directly access the cookie in the condition if you wanted to avoid the `http-request` options in the frontend; it *should* work but I'll leave proving that theorem as an exercise for the reader.

### Caveats

There are some caveats to this method that you should keep in mind.

1. Some dynamic DNS hosts prevent setting wildcard cookies; if the one you're using blocks wildcard cookies then you'll need to switch providers or buy your own domain (and use a CNAME to your DDNS provider).
2. While JWTs are often used with HTTP Bearer Authentication to prevent CSRF, Organizr does not utilize this functionality. This means you'll need to extract the JWT from the cookie rather than the Authentication header, and you will receive no CSRF protection from the JWT. Though the Organizr API method also provides no CSRF protection, so this isn't much of a caveat...

### Organizr config.php

You'll need to extract two UUIDs from your Organizr config.php: `organizrHash` and `uuid`. The Organizr docs give you a grep query to fairly easily extract these.

`organizrHash` is the shared secret used to sign the completed JWT, and HAProxy will need this to validate the signature. `uuid` is used as part of the cookie name. In the following sections they'll be denoted with the following randomly generated pseudo-uuids:

- `organizrHash` will be `ec9381f0-05cf-ORGANIZRHASH-63f9770528f8`
- `uuid` will be `9d8da6ce-ca0e-ORGANIZRUUID-f80dad04f76d`


### Frontend settings

Just a couple lines to add to your option pass-through, to extract the JWT and its signing algorithm from the cookie. You can probably simplify things a little (and get rid of a couple HAProxy warnings) by doing this directly in the ACLs (conditions) we'll be creating later, but this works just fine.

```
# JWT stuff
http-request set-var(txn.bearer) req.cook(organizr_token_9d8da6ce-ca0e-ORGANIZRUUID-f80dad04f76d)
http-request set-var(txn.jwt_alg) var(txn.bearer),jwt_header_query('$.alg')
```

(remember to swap in the `uuid` value from your Organizr config to the cookie name!)

### Backend settings

First, we need a couple conditions, both set to "Custom condition" to make use of pass-through.

1. A condition to validate the JWT signing algorithm; I called this "50_Organizr JWT algo". The pass-through should be `var(txn.jwt_alg) -m str "HS256"`.
2. A condition to validate the JWT signature; I called this one "50_Organizr JWT Success". Set it to `var(txn.bearer),jwt_verify(txn.jwt_alg,"ec9381f0-05cf-ORGANIZRHASH-63f9770528f8") 1` and remember to put in the correct `organizrHash` value.

You'll also need to make a matching rule for each of these; in my case (as in the previous section) I combined those conditions with a condition to match on paths not beginning with `/api/` to ensure that API clients can still access the services.

This makes my end rules and backends very similar to the Organizr API method in the end, just with slightly different custom logic in the frontend and backend to use the cookie instead of the Organizr API. Each service needs to have both rules set in-order (first check the hash algorithm, then validate the token) and they'll all use the same variables extracted in the frontend, which makes everything fairly easy to manage.

## Testing the setup

Make sure your setup works as intended before exposing anything to the internet. I'd recommend setting your frontend to only listen locally, setting up DNS or hosts file entries for your services, and then testing. Try to access the services without logging in to Organizr, make sure you get a 403 page, then log in and make sure you don't. If you miss something, you might accidentally expose your services publicly, and that will probably result in data loss!
