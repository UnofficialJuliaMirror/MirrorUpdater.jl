# MirrorUpdater - Provides functionality for automatically mirroring Julia package repositories

<table>
    <tbody>
        <tr>
            <td>Travis CI</td>
            <td><a href="https://travis-ci.com/UnofficialJuliaMirror/MirrorUpdater.jl/branches"><img src="https://travis-ci.com/UnofficialJuliaMirror/MirrorUpdater.jl.svg?branch=master"></a></td>
        </tr>
        <tr>
            <td>Codecov</td>
            <td><a href="https://codecov.io/gh/UnofficialJuliaMirror/MirrorUpdater.jl"><img src="https://codecov.io/gh/UnofficialJuliaMirror/MirrorUpdater.jl/branch/master/graph/badge.svg" /></a></td>
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
| [1. Setting up GitHub (required)](#setting-up-github-required) |
| [2. Setting up GitLab (optional)](#setting-up-gitlab-optional) |
| [3. Setting up BitBucket (optional)](#setting-up-bitbucket-optional) |
| [4. Setting up Travis (required)](#setting-up-travis-required) |
| [5. Running the updater manually](#running-the-updater-manually) |

## Setting up GitHub (required)

### Step 1

If you do not already have a personal GitHub account, [create one](https://help.github.com/articles/signing-up-for-a-new-github-account/). For the remainder of this README, `MY_PERSONAL_GITHUB_USERNAME` refers to the username of your personal GitHub account.

*For example, for me, `MY_PERSONAL_GITHUB_USERNAME` is equal to `DilumAluthge`.*

### Step 2

Log in to GitHub as `MY_PERSONAL_GITHUB_USERNAME`.

### Step 3

While logged in as `MY_PERSONAL_GITHUB_USERNAME`, [enable two-factor authentication](https://help.github.com/articles/configuring-two-factor-authentication/) on the `MY_PERSONAL_GITHUB_USERNAME` account.

**Make sure to store your two-factor recovery codes in a secure location!**

### Step 4

While logged in as `MY_PERSONAL_GITHUB_USERNAME`, [create a free GitHub organization](https://help.github.com/articles/creating-a-new-organization-from-scratch/) that you will use only for hosting the mirrored repositories. For the remainder of this README, `MY_GITHUB_ORG` refers to the name of this organization. `MY_PERSONAL_GITHUB_USERNAME` should be an `owner` of the `MY_GITHUB_ORG` organization.

*For example, for me, `MY_GITHUB_ORG` is equal to `UnofficialJuliaMirror`.*

### Step 5

Log out of the `MY_PERSONAL_GITHUB_USERNAME` account.

### Step 6

[Create a new GitHub "bot" account](https://help.github.com/articles/signing-up-for-a-new-github-account/) that you will use ONLY for maintaining the mirror. For the remainder of this README, `MY_GITHUB_BOT_USERNAME` refers to the username of this account.

*For example, for me, `MY_GITHUB_BOT_USERNAME` is equal to `UnofficialJuliaMirrorBot`.*

### Step 7

Log in to GitHub as `MY_GITHUB_BOT_USERNAME`.

### Step 8

While logged in as `MY_GITHUB_BOT_USERNAME`, [enable two-factor authentication](https://help.github.com/articles/configuring-two-factor-authentication/) on the `MY_GITHUB_BOT_USERNAME` account.

**Make sure to store your two-factor recovery codes in a secure location!**

### Step 9

While logged in as `MY_GITHUB_BOT_USERNAME`, [create a personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) for the `MY_GITHUB_BOT_USERNAME` account and store it in a secure place (such as a password manager). For the remainder of this README, `my-github-bot-personal-access-token` refers to this personal access token.

**The personal access token should be treated as securely as a password. Do not share it with anyone. Do not save it in any unsecure location. Do not save it in a file. Do not commit it in a Git repository.**

### Step 10

Log out of the `MY_GITHUB_BOT_USERNAME` account. 

### Step 11

Log in to GitHub as `MY_PERSONAL_GITHUB_USERNAME`.

### Step 12

While logged in as `MY_PERSONAL_GITHUB_USERNAME`, go to the `MY_GITHUB_ORG` organization members page (`https://github.com/orgs/UnofficialJuliaMirror/people`).

Add `MY_GITHUB_BOT_USERNAME` as a `member` of the `MY_GITHUB_ORG` organization.

This will allow `MY_GITHUB_BOT_USERNAME` to create new repositories within the `MY_GITHUB_ORG` organization.

### Step 13

While logged in as `MY_PERSONAL_GITHUB_USERNAME`, [fork the MirrorUpdater.jl repository](https://github.com/UnofficialJuliaMirror/MirrorUpdater.jl/fork) to the `MY_GITHUB_ORG` organization.

### Step 14

Go to your fork of MirrorUpdater.jl: `https://github.com/MY_GITHUB_ORG/MirrorUpdater.jl`

### Step 15

In your fork, update line 1 of `config/github.jl` to look like:
```julia
const GITHUB_ORGANIZATION = "MY_GITHUB_ORG"
```

Leave the rest of `config/github.jl` unchanged. Please do not stored your personal access token in the file.

### Step 16

In your fork, update line 1 of `config/enabled-providers.jl` to look like:
```julia
const GITHUB_ENABLED = true
```
### Step 17 (optional)

If there are other registries of Julia packages that you would like to mirror, add them to the `config/registries.jl` file in your fork:

### Step 18 (optional)

Update the other configuration files in the `config/` folder of your fork as you see fit.

**Congratulations, you have finished this section.**

## Setting up GitLab (optional)

GitLab support is coming soon!

## Setting up BitBucket (optional)

BitBucket support is coming soon!

## Setting up Travis (required)

### Step 1

Log in to GitHub as `MY_PERSONAL_GITHUB_USERNAME`.

### Step 2

Log in to Travis using the GitHub account `MY_PERSONAL_GITHUB_USERNAME`: `https://travis-ci.com/`

### Step 3

Enable Travis for your fork: `https://travis-ci.com/profile/MY_GITHUB_ORG`

### Step 4

Go to the Travis settings page for your fork: `https://travis-ci.com/MY_GITHUB_ORG/MirrorUpdater.jl/settings`

### Step 5

In the "Environment Variables" section of the Travis settings page, [add a new environment variable](https://docs.travis-ci.com/user/environment-variables/#defining-variables-in-repository-settings) with name equal to `GITHUB_PERSONAL_ACCESS_TOKEN` and value equal to `my-github-bot-personal-access-token`. **Make sure that the "Display value in build log" option is turned OFF.**

### Step 6

In the "Cron Jobs" section of the Travis settings page, [create a new cron job for your fork](https://docs.travis-ci.com/user/cron-jobs/#adding-cron-jobs). For "Branch", select `master`. For "Interval", select whatever you like (I recommend `daily` or `weekly`). For "Options", select `Always run`.

**Congratulations, you have finished this section.**

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

Set the `GITHUB_PERSONAL_ACCESS_TOKEN` environment variable equal to your GitHub personal access token:

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="my-github-bot-personal-access-token"
```

### Step 6

Run the updater:

```bash
julia --project run-github-mirror-updater.jl
```

**Congratulations, you have finished this section.**
