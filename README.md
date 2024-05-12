# Termux User Repository (TUR) for pacman - official git repo mirror
![GitHub repo size](https://img.shields.io/github/repo-size/termux-pacman/tur)
![Packages-tur last build status](https://github.com/termux-pacman/tur/workflows/Packages-tur/badge.svg)
![Packages-tur-continuous last build status](https://github.com/termux-pacman/tur/workflows/Packages-tur-continuous/badge.svg)
![Repo last update status](https://github.com/termux-pacman/tur/workflows/Update%20repo/badge.svg)  
[More about the repository](https://github.com/termux-user-repository/tur/blob/master/README.md)

### Code for connecting repository:
tur:
```
[tur]
Server = https://service.termux-pacman.dev/tur/$arch
```
tur-continuous:
```
[tur-continuous]
Server = https://service.termux-pacman.dev/tur-continuous/$arch
```
tur-multilib:
```
[tur-multilib]
Server = https://service.termux-pacman.dev/tur-multilib/$arch
```

### Other information:
 - Android support: 7+
 - Architecture support: all (aarch64, arm, x86_64, i686)
 - Security level: full (db and packages are protected by signature)
 - Signature: termux-pacman organization gpg key
 - Powered by aws
 - Root repository: https://github.com/termux-user-repository/tur
 - Organization maintaining the root repository: [termux-user-repository](https://github.com/termux-user-repository)
