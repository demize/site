---
title: "Computers Are Bad: Recovering Bitlocker encrypted fixed drives with only the OS drive's recovery key when the system won't boot"
date: 2018-09-24T16:03:42-04:00
draft: false
---

So, your OS drive got corrupted and won't boot, and you have important data on
the encrypted fixed data drives on your computer. You do have the recovery key
for the OS drive (without that, there *is* no recovery), so there's an easy
solution: restore from a system image. You didn't make a system image? Did you
set a password for the drives? No? Did you only check the box to automatically
unlock the drives? Use the recovery k---what do you mean you *lost the recovery
keys*? Well, this is still salvageable, it's just a bit more complicated.

As you may have been able to figure out, when you set the option to unlock the
drives automatically, it has to store the key somewhere. Your first instinct may
be to try and find where that key is stored and how to extract it. That's not
going to work, though: the keys for auto unlock are stored in the registry, but
they're encrypted through DAPI using the machine's credentials, and likely have
an extra layer of 3DES sprinkled on top just for fun. Extracting them would mean
first extracting the machine credentials, and then figuring out how to decrypt
them. It should be possible, but hasn't been done yet, as far as I can tell.
Besides, there's an easier solution: just boot to the Windows Recovery
Environment.

You know how Windows automatically creates a couple extra partitions when it
installs? One of those is the recovery partition, and contains the Windows
Recovery Environment. Turns out the Windows Recovery Environment will also
automatically unlock Bitlocker-protected fixed data drives, and it even has the
Manage-BDE command built in. This means that if you can boot to the Recovery
Environment and open a command prompt, you can use Manage-BDE to disable
Bitlocker and decrypt the drives, then reinstall the OS. It took me a week to
discover this, and I had to reach out to the IACIS mailing list for help. Now
you don't need to spend a week trying everything else!

Except that's not the end of the story. Opening a command prompt in the Recovery
Environment requires a local password. I didn't have one; my machine was joined
to a domain, and nobody could remember what password was used for the local
Administrator account, which was the only account the Recovery Environment would
let us log in with. You can reset the local Administrator password with a few
different boot CDs (I used the one from Passware, but there are others), but
they only work if the OS drive isn't encrypted. If it is encrypted then you have
yourself yet another problem. Luckily, I work in a digital forensics lab, so
once I knew the Windows Recovery Environment would work, I knew exactly what to
do:

1. Clone your OS drive, encrypted, onto a USB drive. I used Sumuri's Paladin
   boot CD for this, which is free; there are other boot CDs you can use though,
   like Clonezilla's.
2. Use another computer to decrypt the OS drive.
3. While that's happening, make another clone of the OS drive to a different USB
   drive. Don't decrypt this one. I actually did this as a precaution, but it
   actually turned out to be very important!
4. Once the OS drive is decrypted, clone the decrypted drive to your OS drive.
5. Boot to a password reset disc (like Passware's WinKey one, but there are free
   ones out there) and reset the Administrator password.
6. ~~Boot to the Recovery Environment and it works!~~ A very important part of
   autounlock for fixed data drives is that Bitlocker will only let you turn it
   on if your OS drive is encrypted. If you then decrypt your OS drive, it will
   also refuse to decrypt the fixed data drives. To get around this, boot to the
   Recovery Environment, open a command prompt (the password will be blank now),
   and copy your SAM file (usually found at C:\Windows\System32\config\SAM, but
   in the RE drive letters can change) to a USB drive (feel free to format the
   one you used to decrypt your OS drive, you don't need it anymore).
7. Use the second clone of your OS drive to clone the Bitlocker-protected
   version of your OS back to your OS drive.
8. Boot to a Windows installer (preferably for the same version that was
   installed), select the "Repair your PC" option, and open a command prompt.
   You'll have to enter the recovery key for your OS drive, but you can skip any
   other drives it asks about.
9. Copy the SAM file from after you reset the Administrator password onto the
   encrypted OS drive, overwriting the old one.
0. Boot to the Recovery Environment again, open the command prompt again, and
   run `manage-bde -status`. Marvel at how your drives are now unlocked!
1. After figuring out which drives are the ones you want to decrypt, actually
   decrypt them with the command `manage-bde -off X:` (replacing X: with the
   drive letter of the drive you want to decrypt). If you have multiple drives,
   run this command multiple times. It starts decrypting in the background, so
   you can get them all decrypting at once.
2. Keep the Recovery Environment open until the drives decrypt. You don't want
   to be messing around with installing Windows until that's done, just to be
   safe. You can (and have to) monitor the status with
   `manage-bde -status [drive letter]`. The drive letter is optional, and you
   can only specify one at a time. What I did to monitor just the two drives was
   `manage-bde -status A: && manage-bde -status B:`.
3. Once all your drives show as "Fully decrypted", you're good! Reboot,
   reinstall Windows, and try to forget this ever happened.

Of course, there is a faster and better way to do this:

1. Clone your encrypted OS drive to a USB drive
2. Decrypt it using another computer
3. Make a VM, set the decrypted drive as one of its hard drives, and boot to the
   password reset disc in the VM
4. Copy the SAM file from the decrypted drive to the encrypted drive
5. Boot to the Recovery Environment and decrypt the fixed data drives
6. Learn from your mistakes, and after reinstalling Windows make sure you can't
   possibly lose your recovery keys. Set a password as a backup. Make a system
   image of your OS so that it can be restored in case of catastrophic failure.

Needless to say, I have learned from my mistakes. I've done all three on my new
installation of Windows: my fixed data drives now have a password set that both
me and someone else have, my recovery keys similarly have been made permanently
available, and in the case of catastrophic OS failure I do now have a system
image that will restore my machine. A future such crisis has been averted; all
it took was to *have* the crisis.

This post isn't actually very interesting, but I spent a week struggling with
this issue; I hope that this post helps prevent any such issues from happening
to other people, and if it does, I hope this post helps them recover their data.
The data I had wasn't actually *that* important; I was ready to just format the
machine, but I decided to reach out for help before I did that. I'm glad I did.
Your data may be more important than mine was, and now it's easier for you to
recover it in case of a similar failure.
