# MirrorUpdater - Provides functionality for automatically mirroring Julia package repositories
![GitHub]()
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

MirrorUpdater requires Julia version 1.0 or greater.

## Usage

### Step 1

```bash
git clone https://github.com/UnofficialJuliaMirror/MirrorUpdater.jl
```

### Step 2

```bash
cd MirrorUpdater.jl
```

### Step 3

Update the Github organization and Github username in `config/github.jl`.

### Step 4 (optional)

Update the other settings in the `config/` folder as you see fit.

### Step 4.1 (only necessary while we wait for https://github.com/JuliaWeb/GitHub.jl/pull/118 to be merged)

```bash
julia --project -e 'import Pkg; p = Pkg.PackageSpec(name="GitHub", url="https://github.com/DilumAluthge/GitHub.jl", rev="da/fix-create-repo-bug"); Pkg.add(p);'
```

### Step 5

```bash
julia --project -e 'import Pkg; Pkg.resolve();'
```

### Step 6

```bash
julia --project deps/build.jl
```

### Step 7

```bash
export GITHUB_TOKEN="your-github-personal-access-token-goes-here"
```

### Step 8

```bash
julia --project run-github-mirror-updater.jl
```
