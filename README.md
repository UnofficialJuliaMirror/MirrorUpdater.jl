# MirrorUpdater - Provides functionality for automatically mirroring Julia package repositories

<table>
    <tbody>
        <tr>
            <td>Travis CI</td>
            <td><a href="https://travis-ci.com/UnofficialJuliaMirror/MirrorUpdater.jl/branches"><img src="https://travis-ci.com/UnofficialJuliaMirror/MirrorUpdater.jl.svg?branch=master"></a></td>
        </tr>
        <tr>
            <td>Project Status</td>
            <td><a href="https://www.repostatus.org/#active"><img src="https://www.repostatus.org/badges/latest/active.svg" alt="Project Status: Active – The project has reached a stable, usable state and is being actively developed." /></a></td>
        </tr>
        <tr>
            <td>License</td>
            <td><a href="https://github.com/UnofficialJuliaMirror/MirrorUpdater.jl/blob/master/LICENSE"><img title="MIT License" alt="MIT License" src="https://img.shields.io/github/license/mashape/apistatus.svg"></a></td>
        </tr>
    </tbody>
</table>

MirrorUpdater is a Julia module that provides functionality for automatically
mirroring Julia package repositories. It is used to maintain the Julia package
mirrors at
[https://github.com/UnofficialJuliaMirror](https://github.com/UnofficialJuliaMirror).
You can also use it to host your own mirror.

| Table of Contents |
| ----------------- |
| [1. First time setup](#first-time-setup) |
| [2. Running the updater manually](#running-the-updater-manually) |
| [3. Configuring the updater to run automatically via Travis cron jobs](#configuring-the-updater-to-run-automatically-via-travis-cron-jobs) |

## First Time Setup

### Step 1

[Create a free GitHub account](https://help.github.com/articles/signing-up-for-a-new-github-account/) that you will use only for maintaining the mirror. For the remainder of this README, `MY_GITHUB_BOT` refers to the username of this account.

### Step 2

[Create a personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) for the `MY_GITHUB_BOT` account and store it in a secure place (such as a password manager).

### Step 3

[Create a free GitHub organization](https://help.github.com/articles/creating-a-new-organization-from-scratch/) for hosting the mirrored repositories. For the remainder of this README, `MY_GITHUB_ORG` refers to the name of this organization.

### Step 4

[Fork the MirrorUpdater.jl repository](https://github.com/UnofficialJuliaMirror/MirrorUpdater.jl/fork) to the `MY_GITHUB_ORG` organization.

### Step 5

Update lines 1 and 2 of `config/github.jl` to look like:
```julia
const GITHUB_ORGANIZATION = "MY_GITHUB_ORG"
const GITHUB_USER = "MY_GITHUB_BOT"
```

Leave the rest of `config/github.jl` unchanged. Please do not stored your personal access token in the file.

### Step 6 (optional)

If there are other registries of Julia packages that you would like to mirror, add them to the `config/registries.jl` file.

### Step 7 (optional)

Update the other configuration files in the `config/` folder as you see fit.

## Running the updater manually

### Step 1

Download the code from your fork:
```bash
git clone https://github.com/MY_GITHUB_ORG/MirrorUpdater.jl
```

### Step 2

`cd` into the `MirrorUpdater.jl` directory:
```bash
cd MirrorUpdater.jl
```

### Step 3

Update the dependencies of the project:
```bash
julia --project -e 'import Pkg; Pkg.resolve();'
```

### Step 4

Build the project:
```bash
julia --project deps/build.jl
```

### Step 5

Set the `GITHUB_TOKEN` environment variable equal to your GitHub personal access token:

```bash
export GITHUB_TOKEN="your-github-personal-access-token-goes-here"
```

### Step 6

Run the updater:

```bash
julia --project run-github-mirror-updater.jl
```

## Configuring the updater to run automatically via Travis cron jobs

### Step 1

Enable Travis for your fork: [https://travis-ci.com/profile/MY_GITHUB_ORG](https://travis-ci.com/profile/MY_GITHUB_ORG)

### Step 2

Go to the Travis settings page for your fork: [https://travis-ci.com/MY_GITHUB_ORG/MirrorUpdater.jl/settings](https://travis-ci.com/MY_GITHUB_ORG/MirrorUpdater.jl/settings)

### Step 3

In the "Environment Variables" section of the Travis settings page, [add a new environment variable](https://docs.travis-ci.com/user/environment-variables/#defining-variables-in-repository-settings) with name equal to `GITHUB_TOKEN` and value equal to your GitHub personal access token. **Make sure that the "Display value in build log" option is turned OFF.**

### Step 4

In the "Cron Jobs" section of the Travis settings page, [create a new cron job for your fork](https://docs.travis-ci.com/user/cron-jobs/#adding-cron-jobs). For "Branch", select `master`. For "Interval", select whatever you like (I recommend `daily` or `weekly`). For "Options", I recommend selecting `Do not run if there has been a build in the last 24h`.
