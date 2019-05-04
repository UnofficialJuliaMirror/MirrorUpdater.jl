# MirrorUpdater.jl - Provides functionality for automatically mirroring Julia package repositories

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
            <td><a href="LICENSE"><img title="MIT License" alt="MIT License" src="https://img.shields.io/github/license/mashape/apistatus.svg"></a></td>
        </tr>
    </tbody>
</table>

MirrorUpdater.jl is a Julia application that provides functionality for
automatically mirroring Julia package repositories.

MirrorUpdater.jl (and its sibling project, [Snapshots.jl](https://github.com/UnofficialJuliaMirrorSnapshots/Snapshots.jl)) are used to maintain the
Julia package mirrors and snapshots hosted at:

| | Mirrors | Snapshots |
| ------ | ------- | --------- |
| GitHub | [https://github.com/UnofficialJuliaMirror](https://github.com/UnofficialJuliaMirror) | [https://github.com/UnofficialJuliaMirrorSnapshots](https://github.com/UnofficialJuliaMirrorSnapshots) |
| GitLab | [https://gitlab.com/UnofficialJuliaMirror](https://gitlab.com/UnofficialJuliaMirror) | [https://gitlab.com/UnofficialJuliaMirrorSnapshots](https://gitlab.com/UnofficialJuliaMirrorSnapshots) |
| Bitbucket | [https://bitbucket.org/UnofficialJuliaMirror](https://bitbucket.org/UnofficialJuliaMirror) | [https://bitbucket.org/UnofficialJuliaMirrorSnapshots](https://bitbucket.org/UnofficialJuliaMirrorSnapshots) |

You can host your own mirrors for free by following these instructions:

| Table of Contents |
| ----------------- |
| [1. Setting up GitHub (required)](#setting-up-github-required) |
| [2. Setting up GitLab (optional)](#setting-up-gitlab-optional) |
| [3. Setting up BitBucket (optional)](#setting-up-bitbucket-optional) |
| [4. Setting up Travis (required)](#setting-up-travis-required) |
| [5. Running the updater manually](#running-the-updater-manually) |
| [6. Troubleshooting common issues](#troubleshooting-common-issues) |

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

While logged in as `MY_PERSONAL_GITHUB_USERNAME`, go to the `MY_GITHUB_ORG` organization security settings page (`https://github.com/organizations/MY_GITHUB_ORG/settings/security`).

Next, make sure that the checkbox next to "Require two-factor authentication for everyone..." is CHECKED.

Finally, click the "Save" button.

### Step 6

Log out of the `MY_PERSONAL_GITHUB_USERNAME` account.

### Step 7

[Create a new GitHub "bot" account](https://help.github.com/articles/signing-up-for-a-new-github-account/) that you will use ONLY for maintaining the mirror. For the remainder of this README, `MY_GITHUB_BOT_USERNAME` refers to the username of this account.

*For example, for me, `MY_GITHUB_BOT_USERNAME` is equal to `UnofficialJuliaMirrorBot`.*

### Step 8

Log in to GitHub as `MY_GITHUB_BOT_USERNAME`.

### Step 9

While logged in as `MY_GITHUB_BOT_USERNAME`, [enable two-factor authentication](https://help.github.com/articles/configuring-two-factor-authentication/) on the `MY_GITHUB_BOT_USERNAME` account.

**Make sure to store your two-factor recovery codes in a secure location!**

### Step 10

While logged in as `MY_GITHUB_BOT_USERNAME`, [create a personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) for the `MY_GITHUB_BOT_USERNAME` account and store it in a secure place (such as a password manager). For the remainder of this README, `my-github-bot-personal-access-token` refers to this personal access token.

**The personal access token should be treated as securely as a password. Do not share it with anyone. Do not save it in any unsecure location. Do not save it in a file. Do not commit it in a Git repository.**

### Step 11

Log out of the `MY_GITHUB_BOT_USERNAME` account.

### Step 12

Log in to GitHub as `MY_PERSONAL_GITHUB_USERNAME`.

### Step 13

While logged in as `MY_PERSONAL_GITHUB_USERNAME`, go to the `MY_GITHUB_ORG` organization members page (`https://github.com/orgs/UnofficialJuliaMirror/people`).

Then, add `MY_GITHUB_BOT_USERNAME` as a `member` of the `MY_GITHUB_ORG` organization.

This will allow `MY_GITHUB_BOT_USERNAME` to create new repositories within the `MY_GITHUB_ORG` organization.

### Step 14

While logged in as `MY_PERSONAL_GITHUB_USERNAME`, [fork the MirrorUpdater.jl repository](https://github.com/UnofficialJuliaMirror/MirrorUpdater.jl/fork) to the `MY_GITHUB_ORG` organization.

### Step 15

Go to your fork of MirrorUpdater.jl: `https://github.com/MY_GITHUB_ORG/MirrorUpdater.jl`

### Step 16

In your fork, update lines 1 and 2 of `config/github.jl` to look like:
```julia
const GITHUB_ORGANIZATION = "MY_GITHUB_ORG"
const GITHUB_BOT_USERNAME = "MY_GITHUB_BOT_USERNAME"
```

Leave the rest of `config/github.jl` unchanged. Please do not stored your personal access token in the file.

### Step 17

In your fork, update line 1 of `config/enabled-providers.jl` to look like:
```julia
const GITHUB_ENABLED = true
```
### Step 18 (optional)

If there are other registries of Julia packages that you would like to mirror, add them to the `config/registries.jl` file in your fork:

### Step 19 (optional)

Update the other configuration files in the `config/` folder of your fork as you see fit.

**Congratulations, you have finished this section.**

## Setting up GitLab (optional)

### Step 1

If you do not already have a personal GitLab account, [create one](https://gitlab.com/users/sign_in#register-pane). For the remainder of this README, `MY_PERSONAL_GITLAB_USERNAME` refers to the username of your personal GitLab account.

*For example, for me, `MY_PERSONAL_GITLAB_USERNAME` is equal to `DilumAluthge`.*

### Step 2

Log in to GitLab as `MY_PERSONAL_GITLAB_USERNAME`.

### Step 3

While logged in as `MY_PERSONAL_GITLAB_USERNAME`, [enable two-factor authentication](https://docs.gitlab.com/ce/user/profile/account/two_factor_authentication.html#enabling-2fa) on the `MY_PERSONAL_GITLAB_USERNAME` account.

**Make sure to store your two-factor recovery codes in a secure location!**

### Step 4

While logged in as `MY_PERSONAL_GITLAB_USERNAME`, [create a free GitLab group](https://docs.gitlab.com/ce/user/group/#create-a-new-group) that you will use only for hosting the mirrored repositories. For the remainder of this README, `MY_GITLAB_GROUP` refers to the name of this group. `MY_PERSONAL_GITLAB_USERNAME` should be an `owner` of the `MY_GITLAB_GROUP` group.

*For example, for me, `MY_GITLAB_GROUP` is equal to `UnofficialJuliaMirror`.*

### Step 5

While logged in as `MY_PERSONAL_GITLAB_USERNAME`, go to the `MY_GITLAB_GROUP` group general settings page (`https://gitlab.com/groups/MY_GITLAB_GROUP/-/edit`).

Next, scroll down to the "Permissions, LFS, 2FA" section. Click the "Expand" button next to "Permissions, LFS, 2FA" to expand the section.

Then, make sure that the checkbox next to "Require all users in this group to setup Two-factor authentication" is CHECKED.

Finally, click the "Save changes" button.

### Step 6

Log out of the `MY_PERSONAL_GITLAB_USERNAME` account.

### Step 7

[Create a new GitLab "bot" account](https://gitlab.com/users/sign_in#register-pane) that you will use ONLY for maintaining the mirror. For the remainder of this README, `MY_GITLAB_BOT_USERNAME` refers to the username of this account.

*For example, for me, `MY_GITLAB_BOT_USERNAME` is equal to `UnofficialJuliaMirrorBot`.*

### Step 8

Log in to GitLab as `MY_GITLAB_BOT_USERNAME`.

### Step 9

While logged in as `MY_GITLAB_BOT_USERNAME`, [enable two-factor authentication](https://docs.gitlab.com/ce/user/profile/account/two_factor_authentication.html#enabling-2fa) on the `MY_GITLAB_BOT_USERNAME` account.

**Make sure to store your two-factor recovery codes in a secure location!**

### Step 10

While logged in as `MY_GITLAB_BOT_USERNAME`, [create a personal access token](https://docs.gitlab.com/ce/user/profile/personal_access_tokens.html#creating-a-personal-access-token) for the `MY_GITLAB_BOT_USERNAME` account and store it in a secure place (such as a password manager). For the remainder of this README, `my-gitlab-bot-personal-access-token` refers to this personal access token.

**The personal access token should be treated as securely as a password. Do not share it with anyone. Do not save it in any unsecure location. Do not save it in a file. Do not commit it in a Git repository.**

### Step 11

Log out of the `MY_GITLAB_BOT_USERNAME` account.

### Step 12

Log in to GitLab as `MY_PERSONAL_GITLAB_USERNAME`.

### Step 13

While logged in as `MY_PERSONAL_GITLAB_USERNAME`, go to the `MY_GITLAB_GROUP` group members page (`https://gitlab.com/groups/MY_GITLAB_GROUP/-/group_members`).

Then, add `MY_GITLAB_BOT_USERNAME` as a `member` of the `MY_GITLAB_GROUP` group.

This will allow `MY_GITLAB_BOT_USERNAME` to create new repositories within the `MY_GITLAB_GROUP` group.

### Step 14

Go to your **GitHub** fork of MirrorUpdater.jl: `https://github.com/MY_GITHUB_ORG/MirrorUpdater.jl`

### Step 15

In your GitHub fork of MirrorUpdater.jl, update lines 1 and 2 of `config/gitlab.jl` to look like:
```julia
const GITLAB_GROUP = "MY_GITLAB_GROUP"
const GITLAB_BOT_USERNAME = "MY_GITLAB_BOT_USERNAME"
```

Leave the rest of `config/gitlab.jl` unchanged. Please do not stored your personal access token in the file.

### Step 16

In your GitHub fork of MirrorUpdater.jl, update line 2 of `config/enabled-providers.jl` to look like:
```julia
const GITLAB_ENABLED = true
```

**Congratulations, you have finished this section.**

## Setting up BitBucket (optional)

### Step 1

If you do not already have a personal Bitbucket account, [create one](https://bitbucket.org/account/signup/). For the remainder of this README, `MY_PERSONAL_BITBUCKET_USERNAME` refers to the username of your personal Bitbucket account.

*For example, for me, `MY_PERSONAL_BITBUCKET_USERNAME` is equal to `DilumAluthge`.*

### Step 2

Log in to Bitbucket as `MY_PERSONAL_BITBUCKET_USERNAME`.

### Step 3

While logged in as `MY_PERSONAL_BITBUCKET_USERNAME`, [enable two-factor authentication](https://confluence.atlassian.com/bitbucket/two-step-verification-777023203.html#Two-stepverification-Enabletwo-stepverification) on the `MY_PERSONAL_BITBUCKET_USERNAME` account.

**Make sure to store your two-factor recovery codes in a secure location!**

### Step 4

While logged in as `MY_PERSONAL_BITBUCKET_USERNAME`, [create a free Bitbucket team](https://confluence.atlassian.com/bitbucket/create-and-administer-your-team-665225537.html) that you will use only for hosting the mirrored repositories. For the remainder of this README, `MY_BITBUCKET_TEAM` refers to the name of this team. `MY_PERSONAL_BITBUCKET_USERNAME` should be an `owner` of the `MY_BITBUCKET_TEAM` team.

*For example, for me, `MY_BITBUCKET_TEAM` is equal to `UnofficialJuliaMirror`.*

### Step 5

While logged in as `MY_PERSONAL_BITBUCKET_USERNAME`, go to the `MY_BITBUCKET_TEAM` projects page (`https://bitbucket.org/MY_BITBUCKET_TEAM/profile/projects`).

Then, create a new project inside the `MY_BITBUCKET_TEAM` team. **Make sure to UNCHECK the box next to "This is a private project." We want this project to be a public project.**

For the remainder of this README, `MY_BITBUCKET_PROJECT` refers to the name of this project.

*For example, for me, `MY_BITBUCKET_PROJECT` is equal to `UnofficialJuliaMirrorProject`.*

### Step 6

Log out of the `MY_PERSONAL_BITBUCKET_USERNAME` account.

### Step 7

[Create a new Bitbucket "bot" account](https://bitbucket.org/account/signup/) that you will use ONLY for maintaining the mirror. For the remainder of this README, `MY_BITBUCKET_BOT_USERNAME` refers to the username of this account.

*For example, for me, `MY_BITBUCKET_BOT_USERNAME` is equal to `UnofficialJuliaMirrorBot`.*

### Step 8

Log in to Bitbucket as `MY_BITBUCKET_BOT_USERNAME`.

### Step 9

While logged in as `MY_BITBUCKET_BOT_USERNAME`, [enable two-factor authentication](https://confluence.atlassian.com/bitbucket/two-step-verification-777023203.html#Two-stepverification-Enabletwo-stepverification) on the `MY_BITBUCKET_BOT_USERNAME` account.

**Make sure to store your two-factor recovery codes in a secure location!**

### Step 10

While logged in as `MY_BITBUCKET_BOT_USERNAME`, [create an app password](https://confluence.atlassian.com/bitbucket/app-passwords-828781300.html#Apppasswords-Createanapppassword) for the `MY_BITBUCKET_BOT_USERNAME` account and store it in a secure place (such as a password manager). For the remainder of this README, `my-bitbucket-bot-app-password` refers to this app password.

**The app password should be treated as securely as any other password. Do not share it with anyone. Do not save it in any unsecure location. Do not save it in a file. Do not commit it in a Git repository.**

### Step 11

Log out of the `MY_BITBUCKET_BOT_USERNAME` account.

### Step 12

Log in to Bitbucket as `MY_PERSONAL_BITBUCKET_USERNAME`.

### Step 13

While logged in as `MY_PERSONAL_BITBUCKET_USERNAME`, go to the `MY_BITBUCKET_TEAM` team members page (`https://bitbucket.org/MY_BITBUCKET_TEAM/profile/members`).

Then, add `MY_BITBUCKET_BOT_USERNAME` as a `member` of the `MY_BITBUCKET_TEAM` team.

This will allow `MY_BITBUCKET_BOT_USERNAME` to create new repositories within the `MY_BITBUCKET_TEAM` team.

### Step 14

Go to your **GitHub** fork of MirrorUpdater.jl: `https://github.com/MY_GITHUB_ORG/MirrorUpdater.jl`

### Step 15

In your GitHub fork of MirrorUpdater.jl, update lines 1 and 2 of `config/bitbucket.jl` to look like:
```julia
const BITBUCKET_TEAM = "MY_BITBUCKET_TEAM"
const BITBUCKET_BOT_USERNAME = "MY_BITBUCKET_BOT_USERNAME"
```

Leave the rest of `config/bitbucket.jl` unchanged. Please do not stored your personal access token in the file.

### Step 16

In your GitHub fork of MirrorUpdater.jl, update line 3 of `config/enabled-providers.jl` to look like:
```julia
const BITBUCKET_ENABLED = true
```

**Congratulations, you have finished this section.**

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

In the "General" section of the Travis settings page, turn ON the switch next to "Limit concurrent jobs". Then, enter `1` in the box to the right.

*This step is important. You must limit the concurrent jobs to 1. If you do not, then you will probably trigger the API rate limits for GitHub, GitLab, and/or Bitbucket, which will cause your Travis jobs to fail.*

### Step 6

In the "Environment Variables" section of the Travis settings page, [add a new environment variable](https://docs.travis-ci.com/user/environment-variables/#defining-variables-in-repository-settings) with name equal to `GITHUB_BOT_PERSONAL_ACCESS_TOKEN` and value equal to `my-github-bot-personal-access-token`. **Make sure that the "Display value in build log" option is turned OFF.**

### Step 7

In the "Cron Jobs" section of the Travis settings page, [create a new cron job for your fork](https://docs.travis-ci.com/user/cron-jobs/#adding-cron-jobs). For "Branch", select `master`. For "Interval", select `weekly`. For "Options", select `Do not run if there has been a build in the last 24h`.

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

Install the dependencies of the project:
```bash
julia --project -e 'import Pkg; Pkg.resolve();'
```

### Step 4

Build the project:
```bash
julia --project -e 'import Pkg; Pkg.build("MirrorUpdater");'
```

### Step 5

Run the package tests:
```bash
julia --project -e 'import Pkg; Pkg.test("MirrorUpdater");'
```

### Step 6

Set the appropriate environment variables:
```bash
export GITHUB_BOT_PERSONAL_ACCESS_TOKEN="my-github-bot-personal-access-token"

export GITLAB_BOT_PERSONAL_ACCESS_TOKEN="my-gitlab-bot-personal-access-token"

export BITBUCKET_BOT_APP_PASSWORD="my-bitbucket-bot-app-password"
```

### Step 7

Run the updater:
```bash
julia --project run-github-mirror-updater.jl
```

**Congratulations, you have finished this section.**

## Troubleshooting common issues

| Issue | Solution |
| ----- | -------- |
| You get an error of the form "remote: GitLab: You are not allowed to force push code to a protected branch on this project" when trying to push to a remote of the form `https://MY_GITLAB_BOT_USERNAME:[secure]@gitlab.com/MY_GITLAB_GROUP/EXAMPLE-REPO-NAME` | Go to `https://gitlab.com/MY_GITLAB_GROUP/EXAMPLE-REPO-NAME/settings/repository`, click on the "Expand" button next to "Protected Branches", and unprotect all of the protected branches. |
