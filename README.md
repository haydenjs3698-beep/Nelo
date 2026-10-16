# Nelo for iPhone

A schedule app in the Nelo colours. Month view, upcoming list, add and edit events, tick things off, and optionally copy an event into the iPhone Calendar app. Your events are stored on the phone.

You do not need a Mac. GitHub builds the app file for you, and Sideloadly puts it on your phone from Windows.

## 1. Build the app on GitHub (about 10 minutes)

1. Make a free account at github.com and sign in.
2. Click **+** at the top right, then **New repository**. Name it `nelo`. Choose **Public** (macOS builds are free for public repositories), then click **Create repository**.
3. On the new repository page click **uploading an existing file**.
4. Unzip this folder on your PC. Open it, select **everything inside** (the `.github` folder, `Sources` folder, `project.yml` and `README.md`) and drag it all into the GitHub page. Make sure the `.github` folder came across.
5. Click **Commit changes**.
6. Click the **Actions** tab. A build called **Build iPhone app** starts by itself. Wait for the green tick (about 5 to 8 minutes).
7. Click the finished build, scroll to **Artifacts** at the bottom, and download **Nelo-ipa**. Unzip it. Inside is `Nelo.ipa`.

If the build shows a red cross, click it, copy the error text, and send it to Claude to fix.

## 2. Turn on Developer Mode on the iPhone

Settings > Privacy & Security > Developer Mode > on. The phone restarts and asks you to confirm.

## 3. Install with Sideloadly on Windows

1. Install **iTunes** and **iCloud** from apple.com (the downloads from Apple's own site, not the Microsoft Store versions).
2. Install **Sideloadly** from sideloadly.io.
3. Plug the iPhone into the PC with a cable and tap **Trust** on the phone.
4. Drag `Nelo.ipa` into Sideloadly, type your Apple ID, and click **Start**. A separate Apple ID that you only use for this is a good idea.
5. On the phone open Settings > General > VPN & Device Management, tap your Apple ID, and tap **Trust**.
6. Open Nelo.

A free Apple ID lets the app run for 7 days. After that, plug the phone in and install again from Sideloadly. Your events stay on the phone when you reinstall over the top.

## What is and is not in this version

In: upcoming list, month calendar, add, edit and delete, done ticks, copy to iPhone Calendar.

Not in: the AI prompt and the Gmail suggestions from the web version. Those need an Anthropic API key and a Google developer setup, so they can be added later as a second step.
