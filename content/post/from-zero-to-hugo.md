---
title: "From Zero to Hugo"
date: 2022-11-03T18:15:00-04:00
description: "A thorough guide on setting up a static site on Azure with Hugo."
draft: false
---

Recently, a friend opined about wanting to set up a site, but wasn't sure how.
I asked for a bit more info, and since it sounds like he'll be well-served by a
static site generator, I figured I'd throw together this post.

The site you're reading right now is set up this way, though it has years of
baggage from different ways of hosting it, different ways of integrating the
themes, etc... hopefully, this guide will provide a good starting point. I'm
very happy with how I've got this set up, despite not posting to this site very
often, and (aside from your domain) it's completely free. It's also pretty easy
to use, once you've got it set up.

{{< toc >}}

## Introduction (or: Why should I host a site like this?)

I've been running this blog for a while, and it's gone through a few different
hosting methods. But before I was generating it with Hugo, I went through some
other options: Wordpress, Ghost, probably others. Using a traditional blogging
platform is nice, but either you have to host it on their SaaS platform (like
wordpress dot com) or host it yourself, and dynamic sites can be a pain to run (
and have security flaws if you don't keep the *software* updated). So eventually
I switched to static site generation with Hugo; first hosting it manually, then
updating automatically with a commit hook and Caddy, and finally the method I'm
detailing here.

I still like Hugo, over other static site generators, for a few reasons. It's
easy to configure, it has built-in support in Azure Static Web Apps, theming is
fairly easy using Git Submodules... but most importantly, posts and pages are
written in Markdown, which is as close to a universally-understood markup
language as we've ever seen. And combined with configuration being done through
TOML, and a large community built up around the app, that makes Hugo pretty darn
accessible to most people.

But that doesn't stop it from being daunting! Even if you're reasonably
technical, if you don't have experience hosting a website, then having to figure
out how (and where) to host a static site might be a pain. So that's why we're
here.

The benefit to hosting a Hugo site on Azure Static Web Apps is that you get free
hosting from a major cloud provider, and aside from the initial configuration,
all you need to do to maintain the site is write posts in Markdown and push them
to Github. The process is front-loaded, the hard parts come first, and once you've
done the hard parts the rest is pretty smooth. So if all you need is a simple
site, where you can host your own pages and/or blog posts... it's an excellent
solution.

Everything I did for this post is public, so you can go take a look if you want:

- [Github](https://github.com/demize/demo-site)
- The site itself: https://demize.dev or https://ashy-ocean-02ca66910.2.azurestaticapps.net

*This* site is also public, so you can check it out [on Github](https://github.com/demize/site)
if you'd like a more detailed example.

## Prerequisites

This may be called "From Zero to Hugo", but it won't be a truly comprehensive
guide. Resources you may find useful include:

- [John Gruber's Markdown specification](https://daringfireball.net/projects/markdown/)
  or the [Github Flavored Markdown specification](https://github.github.com/gfm/).
  It's not as daunting as it looks--and if you've been using Discord or Reddit,
  you probably already know most of this.
- The official [Hugo Quick Start guide](https://gohugo.io/getting-started/quick-start/).
  We'll cover a bit of this here, but this guide is more about getting it hosted
  and less about designing it.
- Microsoft has [their own version](https://learn.microsoft.com/en-us/azure/static-web-apps/publish-hugo)
  of this guide. Had I remembered this existed, I may not have written this!
  It's pretty similar to mine, because it covers mostly the same topics, but it
  also has a bit of extra information at the end (and I think mine has a bit
  more of the basic information... so they *may* sort of compliment each other).

You'll also want to own a domain name; any one will do, as long as you own it. I
strongly recommend registering it with (or transferring it to) [Gandi](https://gandi.net),
though you'll be fine with whatever registrar; ideally you'll have one that
supports ALIAS records on the apex domain, and that's what I'll assume you have.

### Things to install

You'll need to install a few things to be able to create your site. If you use
Windows, I'd recommend setting up Windows Subsystem for Linux (WSL) and using it
for this, however all the requirements will work on any system. You'll need:

- Git ([Git for Windows](https://gitforwindows.org/) on Windows)
- Hugo (You may want to jump to the
  [Less-technical Users](https://gohugo.io/getting-started/installing#less-technical-users)
  section of its install guide). Make sure it's on your PATH!
- A text editor. Please don't use Notepad. [VS Code](https://code.visualstudio.com/)
  will get you good syntax highlighting, and built-in Git integration.
- A terminal. This is already on your system, but you'll need to use it, so I'll
  mention it here. This can be `cmd.exe`, but you'll have a better time in...
  anything else.

### Accounts you'll need

You will need a couple accounts to do this:

- A Github (or Azure DevOps) account
- A Microsoft account to log in to Azure with

## Creating the site

Assuming you don't yet have a Hugo site, you'll need to create one. Following
mostly the instructions from the Hugo quick start guide:

```console
$ mkdir new-site
$ hugo new site new-site
Congratulations! Your new Hugo site is created in /home/demize/projects/new-site.
...
$ cd new-site
$ git init
Initialized empty Git repository in /home/demize/projects/new-site/.git/
$ git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke
Cloning into '/home/demize/projects/new-site/themes/ananke'...
...
$ echo theme = \"ananke\" >> config.toml
$ hugo new posts/my-first-post.md
Content "/home/demize/projects/new-site/content/posts/my-first-post.md" created
$ # Make the post something that will render on Azure
$ sed -i 's/true/false/' content/posts/my-first-post.md
$ echo "Welcome to my new Hugo site hosted on Azure!" >> content/posts/my-first-post.md
$ # Make sure we aren't adding the built files to Git
$ echo "public/" >> .gitignore
```

This will get you a very basic site, but it's enough for us to push to Azure.
The getting started guide continues on with some more information on customizing
your theme, and I would recommend making sure the site is set up how you want it
before proceeding.

## Hosting the site on Github

Once you've got the initial setup done, you'll need to put the site's code on
Github so it can be pushed to Azure automatically—that's why you're here, right?

You could also use Azure DevOps for this, and the process would be largely the
same, but I'll assume you're using Github.

This is a pretty simple process, and Github will guide you through most of it:

1. Run `hugo` with no arguments to make sure your site builds properly. If it
   fails to build, it won't deploy, and that will probably cause you some issues
   in the next section. You should see an output like this:
   ```console
   $ hugo
   Start building sites …
   hugo v0.105.0-0e3b42b4a9bdeb4d866210819fc6ddcf51582ffa linux/amd64 BuildDate=2022-10-28T12:29:05Z     VendorInfo=gohugoio

                      | EN
   -------------------+-----
     Pages            | 10
     Paginator pages  |  0
     Non-page files   |  0
     Static files     |  1
     Processed images |  0
     Aliases          |  1
     Sitemaps         |  1
     Cleaned          |  0

   Total in 22 ms
   ```
2. Make sure your code is committed locally:
   ```console
   $ git add .
   $ git commit -m "Initial site setup"
   [master (root-commit) 970bac1] Initial site setup
   6 files changed, 20 insertions(+)
   create mode 100644 .gitmodules
   create mode 100644 .hugo_build.lock
   create mode 100644 archetypes/default.md
   create mode 100644 config.toml
   create mode 100644 content/posts/my-first-post.md
   create mode 160000 themes/ananke
   ```
3. [Create a new repository](https://github.com/new) on Github. Give it whatever
   name you want, and make it public or private, either's fine (though you may
   prefer private). Make sure you leave all the options under "Initialize this
   repository with:" blank, or you'll run into some issues.
4. Run the commands from the "push an existing repository from the command line"
   section on the next page (note that your commands will be slightly different
   than mine):
   ```console
   $ git remote add origin git@github.com:demize/demo-site.git
   $ git branch -M main
   $ git push -u origin main
   Enumerating objects: 11, done.
   Counting objects: 100% (11/11), done.
   Delta compression using up to 16 threads
   Compressing objects: 100% (6/6), done.
   Writing objects: 100% (11/11), 1.11 KiB | 1.11 MiB/s, done.
   Total 11 (delta 0), reused 0 (delta 0)
   To github.com:demize/demo-site.git
   * [new branch]      main -> main
   Branch 'main' set up to track remote branch 'main' from 'origin'.
   ```

And now your site is hosted on Github! But we still need to put it on Azure.

## Hosting the site as a Static Web App on Azure

This is probably the scariest part, but it's actually pretty easy.

1. Log in to the [Azure Portal](https://portal.azure.com).
2. Search for `Static Web Apps` in the top search bar and click on the matching
   result.
3. Click the `➕ Create` button on the following page.
4. You'll need to provide a bunch of information here:
   - You should only have one subscription, and it should be selected by default.
   - You may need to create a new "Resource Group" under the subscription. It
     doesn't really matter what resource group you use; I went with `demo-site`
     for the example I'm using for this post.
   - Similarly, you need to name the web app, and I named mine `demo-site`.
   - You probably want the Free plan.
   - Select whichever Azure region you want; the closest one to you is always a
     good choice.
   - Connect your Github (or Azure DevOps) account, and select the appropriate
     repository from the dropdowns.
   - Select the `Hugo` build preset, and leave the default options unless you
     know what you're doing.
5. Once you've completed all that information, continue to `Review + create` and
   create the app.
6. Once the deployment is complete, you'll get a notification in the Azure
   portal saying it's complete; click the "Go to resource" button in that to go
   to the resource.
7. In another tab, open your Github repository and go to the "Actions" tab.
   Monitor the `ci: add Azure Static Web Apps workflow file` action to know when
   your site should be ready, and wait until the action completes to move on.
8. Back on Azure, you should see a URL listed under the "Essentials" section.
   Open this URL to go see your site on the internet!

You'll also probably need to edit the workflow files that Azure generated here.
Run `git pull` to get them locally, then edit
`.github/workflows/azure-static-web-apps-[random bits].yml` and change the line
`- uses: actions/checkout@v2` to say `- uses: actions/checkout@v3` (that is,
change `v2` to `v3`). If the line already says `v3`, you're fine, but it may not
have been generated with the current version specified there.

You may also want to add, immediately below `submodules: true`, a line reading
`fetch-depth: 0`. This lets certain themes gather more information about your
commit history to determine information like when posts were last updated, so
it's not a bad idea to set.

Make sure to add, commit, and push this change, though feel free to wait until
you've added a new post or page to push.

Now, technically you can stop here, but do you really want your site URL to be
something like `ashy-ocean-02ca66910.2.azurestaticapps.net`?

## Setting up a custom domain

Thankfully, custom domains are pretty easy to set up on Azure, and Azure will
guide you through most of it. Go to the "Custom domains" page from the menu on
the left (under Settings), click the `➕ Create` button, and follow the
instructions (see also their
[help article](https://learn.microsoft.com/en-ca/azure/static-web-apps/custom-domain?wt.mc_id=azurestaticwebapps_inline_inproduct_general#create-an-alias-record)).

You'll need to go to your domain registrar and edit your DNS records there. You
need to create two new records for the domain (or subdomain) you want to use:
a TXT record, with the random value given to you by Azure, and an ALIAS or CNAME
record with the domain Azure generated for your site. You'll need an ALIAS
record for an apex domain (like `demize.dev`) or a CNAME record for a subdomain
(like `demize.unstable.systems`). Make sure you're **not** including the 
`https://` part!

Once you've added the two new records, and once Azure validates the domain, 
Azure will automatically provision an SSL certificate for it through DigiCert,
so even if your domain is on the HSTS preload list, you'll be good now. DNS can
take a while to update, so this could take anywhere from a few minutes to a few
hours, unfortunately.

## Adding new posts

Now comes the fun part! Adding and publishing new posts with this workflow feels
a bit magical.

Add a new post, edit it (make sure to set "draft" to false!), add it, commit it,
and push it like you did with the first post:

```console
$ hugo new posts/my-second-post.md
Content "/home/demize/projects/new-site/content/posts/my-second-post.md" created
$ # Edit this post in your favorite text editor
$ git add content/posts/my-second-post.md
$ git commit -m "Added my second post\!"
[main 96e6a97] Added my second post!
 2 files changed, 8 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 content/posts/my-second-post.md
$ git push
Enumerating objects: 9, done.
Counting objects: 100% (9/9), done.
Delta compression using up to 16 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (6/6), 804 bytes | 804.00 KiB/s, done.
Total 6 (delta 1), reused 0 (delta 0)
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To github.com:demize/demo-site.git
   0b91c98..96e6a97  main -> main
```

Now go back to Github, check the Actions page on your repository, and watch as
it deploys automatically to Azure. After a minute or two, refresh your site, and
you should see the second post listed!

To summarize this process a bit:

1. Create a post, edit a post, make any changes you want
2. Once you've made all the changes you're making, add them to git with `git add`
   (either `git add .` to add all the files, or `git add [list of files]` to add
   specific files)
3. Commit the changes to git with `git commit` (`git commit -m "commit message"`
   to include the commit message on the command line)
4. Push your changes to Github with `git push`
5. The site will update itself!

## Notes and caveats

Some miscellaneous notes and caveats with this method:

- Because the site is statically generated, if you make a post with a date in
  the future, it won't show up on the site even after that date. You can either
  make sure that the post has a date in the past when you push your changes,
  or you can go to Github and manually trigger the action to deploy it to Azure,
  but because of how this process abstracts away the actual site generation,
  it's easy enough to get tripped up by this.

(There's only the one for now; this section may be updated in the future.)

## Conclusion

Hopefully by this point you've got a site hosted on Azure for free, and deployed
to Azure by a Github action when you push to the `main` branch. The only changes
you should need to make at this point will be to your site itself, whether to
the site config or to the posts and pages themselves... and when you make those
changes, it should update automatically on Azure.

If you've got any issues, think there's anything I need to cover better, or just
have any other feedback on this guide, please let me know! You probably already
know how to contact me, but my [contact page](/contact) has all the methods you
can use.

## Errata

No changes have been made to this document yet. This section will be updated as
changes are made, or this notice will remain if no updates are made.
