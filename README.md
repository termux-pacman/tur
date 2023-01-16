# Termux User Repository (TUR) for pacman - official support
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

### Other information:
 - Android support: 7+
 - Architecture support: all (aarch64, arm, x86_64, i686)
 - Security level: full (db and packages are protected by signature)
 - Signature: termux-pacman organization gpg key
 - Storage: aws s3 (US)
 - Mirrors: does not exist
 - Root repository: https://github.com/termux-user-repository/tur
 - Organization maintaining the root repository: [termux-user-repository](https://github.com/termux-user-repository)
