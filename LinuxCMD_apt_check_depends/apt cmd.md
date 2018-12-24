
# REF link
- [Ref link](https://www.tecmint.com/useful-basic-commands-of-apt-get-and-apt-cache-for-package-management/)

## How Do I Check Dependencies for Specific Packages?
- cmd: ```apt-cache showpkg <package name>```
- Use the `showpkg` sub command to check the dependencies for particular software packages. whether those dependencies packages are installed or not. For example, use the ‘showpkg‘ command along with package-name.
```
ubuntu@ip-172-28-3-11:~$ apt-cache showpkg postgresql-9.6
Package: postgresql-9.6
Versions: 
9.6.11-1.pgdg16.04+1 (/var/lib/apt/lists/apt.postgresql.org_pub_repos_apt_dists_xenial-pgdg_main_binary-amd64_Packages)
 Description Language: 
                 File: /var/lib/apt/lists/apt.postgresql.org_pub_repos_apt_dists_xenial-pgdg_main_binary-amd64_Packages
                  MD5: 8c53dfc5193ff055083970fce27a5853
Reverse Depends: 
  postgresql-9.6-dbg,postgresql-9.6 9.6.11-1.pgdg16.04+1
  postgresql-q3c,postgresql-9.6
  ...
Dependencies: 
9.6.11-1.pgdg16.04+1 - locales (0 (null)) postgresql-client-9.6 (0 (null)) postgresql-common (2 171~) ssl-cert (0 (null)) tzdata (0 (null)) libc6 (2 2.15) libgssapi-krb5-2 (2 1.8+dfsg) libldap-2.4-2 (2 2.4.7) libpam0g (2 0.99.7.1) libpq5 (2 9.3~) libssl1.0.0 (2 1.0.0) libsystemd0 (0 (null)) libxml2 (2 2.7.4) postgresql-contrib-9.6 (0 (null)) sysstat (0 (null)) locales-all (0 (null)) 
Provides: 
9.6.11-1.pgdg16.04+1 - 
Reverse Provides: 
```  

## How to download package not install it with apt-get command?
- cmd: ```apt-get install --download-only <package name>```
- Use option `--download-only` will:
  + This will **download `<package name>` and any dependencies you need**, and place them in **/var/cache/apt/archives**. 
  + That way a subsequent apt-get install **`<package name>`** will be able to complete without any extra downloads.
```
ubuntu@ip-172-28-3-11:~$ sudo apt-get install --download-only postgresql-9.6
sudo: unable to resolve host ip-172-28-3-11
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  libsensors4 postgresql-client-9.6 postgresql-client-common postgresql-common postgresql-contrib-9.6 sysstat
Suggested packages:
  lm-sensors locales-all postgresql-doc-9.6 libjson-perl libdbd-pg-perl isag
The following NEW packages will be installed:
  libsensors4 postgresql-9.6 postgresql-client-9.6 postgresql-client-common postgresql-common postgresql-contrib-9.6 sysstat
0 upgraded, 7 newly installed, 0 to remove and 40 not upgraded.
```
## Dont install recommend:
- User option: **--no-install-recommends**

## How do I list all installed packages
- cmd: `apt list --installed <package name>`
```
ubuntu@ip-172-28-1-200:~$ sudo apt list --installed python-docker*
sudo: unable to resolve host ip-172-28-1-200
Listing... Done
python-docker/xenial-updates,now 1.9.0-1~16.04.1 all [installed]
```
## How do i uninstall a packages:
- **Remove only the binaries**, ***remain***: **conf or data files of the package `<packagename>`; also leave dependencies installed** with it on installation time untouched.
```
apt-get remove packagename
```
- **Remove about everything regarding the package `<packagename>`**, ***remain***: **dependencies installed**.
`apt-get purge packagename or apt-get remove --purge packagename\n `
    + Particularly ***useful when you want to 'start all over' with an application because you messed up the config***.
    + However, ***it does not remove configuration or data files residing in users home directories***, usually in hidden folders there. There is no easy way to get those removed as well.
 - **Only Remove the dependencies packages installed**:
 ```
 apt-get autoremove
 ```
 =>> ***Combine autoremove(remove dependencies) + purge(rm package binary and conf or data files)***: to remove package completely: remove 
 ```
 sudo apt-get --purge autoremove packagename
 ```
