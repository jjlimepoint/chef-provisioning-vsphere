# Change Log

## [v2.3.0](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.3.0)

[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v2.2.2...v2.3.0)

**Merged pull requests:**

- Fix missing\_method deprecation from Cheffish::MergedConfig [\#88](https://github.com/chef-partners/chef-provisioning-vsphere/pull/88) ([josh-barker](https://github.com/josh-barker))
- Trying to make travis happy [\#87](https://github.com/chef-partners/chef-provisioning-vsphere/pull/87) ([jjasghar](https://github.com/jjasghar))
- Trying to get back to standards [\#86](https://github.com/chef-partners/chef-provisioning-vsphere/pull/86) ([jjasghar](https://github.com/jjasghar))

## [v2.2.2](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.2.2) (2018-06-05)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v2.2.1...v2.2.2)

**Merged pull requests:**

- Fix bug where ip address is not returned from guest tools [\#85](https://github.com/chef-partners/chef-provisioning-vsphere/pull/85) ([josh-barker](https://github.com/josh-barker))

## [v2.2.1](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.2.1) (2018-06-04)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v2.2.0...v2.2.1)

**Merged pull requests:**

- Fixes bug where additional disks added twice [\#84](https://github.com/chef-partners/chef-provisioning-vsphere/pull/84) ([josh-barker](https://github.com/josh-barker))

## [v2.2.0](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.2.0) (2018-06-01)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v2.1.0...v2.2.0)

**Merged pull requests:**

- Save VM properties to kitchen state file after cloning [\#83](https://github.com/chef-partners/chef-provisioning-vsphere/pull/83) ([josh-barker](https://github.com/josh-barker))
- allow chef14 [\#82](https://github.com/chef-partners/chef-provisioning-vsphere/pull/82) ([jjlimepoint](https://github.com/jjlimepoint))
- Main disk size and rework of ip\_to\_bootstrap\(\) [\#72](https://github.com/chef-partners/chef-provisioning-vsphere/pull/72) ([algaut](https://github.com/algaut))

## [v2.1.0](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.1.0) (2018-03-02)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v2.0.10...v2.1.0)

**Closed issues:**

- Setting network\_name disconnects all devices on OSX [\#62](https://github.com/chef-partners/chef-provisioning-vsphere/issues/62)
- IPv6 address returned by VM can cause failures [\#52](https://github.com/chef-partners/chef-provisioning-vsphere/issues/52)

**Merged pull requests:**

- Handle IPv6 address returned by VM [\#81](https://github.com/chef-partners/chef-provisioning-vsphere/pull/81) ([jzinn](https://github.com/jzinn))
- fixed bootstrap ready timeout call [\#73](https://github.com/chef-partners/chef-provisioning-vsphere/pull/73) ([tuccimon](https://github.com/tuccimon))
- add initial\_iso\_image to support deployment from custom iso images [\#49](https://github.com/chef-partners/chef-provisioning-vsphere/pull/49) ([jjlimepoint](https://github.com/jjlimepoint))

## [v2.0.10](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.0.10) (2017-10-31)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v2.0.9...v2.0.10)

**Closed issues:**

- Undefined method `match?' for "machine\_name":String [\#65](https://github.com/chef-partners/chef-provisioning-vsphere/issues/65)

**Merged pull requests:**

-  Fixed RuboCop and clone\_spec\_builder match? -\> match [\#64](https://github.com/chef-partners/chef-provisioning-vsphere/pull/64) ([bemehiser](https://github.com/bemehiser))

## [v2.0.9](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.0.9) (2017-10-30)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v2.0.8...v2.0.9)

**Closed issues:**

- Networks under a distributed switch not at the rootFolder cannot be found [\#56](https://github.com/chef-partners/chef-provisioning-vsphere/issues/56)

**Merged pull requests:**

- Several small fixes [\#63](https://github.com/chef-partners/chef-provisioning-vsphere/pull/63) ([algaut](https://github.com/algaut))

## [v2.0.8](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.0.8) (2017-10-23)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v2.0.7...v2.0.8)

**Closed issues:**

- Action :destroy fails on powered off VM [\#59](https://github.com/chef-partners/chef-provisioning-vsphere/issues/59)

**Merged pull requests:**

- rubocop -a && rubocop  --auto-gen-config [\#61](https://github.com/chef-partners/chef-provisioning-vsphere/pull/61) ([bemehiser](https://github.com/bemehiser))

## [v2.0.7](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.0.7) (2017-10-19)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v2.0.6...v2.0.7)

**Closed issues:**

- Cannot assign requested address - bind\(2\) for \[::1\]:8889 [\#58](https://github.com/chef-partners/chef-provisioning-vsphere/issues/58)

**Merged pull requests:**

- Solve \#59: action :destroy fails on powered off VM [\#60](https://github.com/chef-partners/chef-provisioning-vsphere/pull/60) ([algaut](https://github.com/algaut))
- Added single-host config info [\#57](https://github.com/chef-partners/chef-provisioning-vsphere/pull/57) ([akulbe](https://github.com/akulbe))
- typo [\#55](https://github.com/chef-partners/chef-provisioning-vsphere/pull/55) ([netflash](https://github.com/netflash))

## [v2.0.6](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.0.6) (2017-07-24)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v2.0.5...v2.0.6)

**Closed issues:**

- Error: ArgumentError: wrong number of arguments \(given 0, expected 1..2\) When provisioning  [\#51](https://github.com/chef-partners/chef-provisioning-vsphere/issues/51)
- action :destroy doesn't work, OR nodes/MACHINE.json not being written out. [\#43](https://github.com/chef-partners/chef-provisioning-vsphere/issues/43)
- Failing to test WinRM availability when creating vm [\#35](https://github.com/chef-partners/chef-provisioning-vsphere/issues/35)

**Merged pull requests:**

- moving to development depenadcy [\#54](https://github.com/chef-partners/chef-provisioning-vsphere/pull/54) ([jjasghar](https://github.com/jjasghar))
- Adding github pull request setup [\#48](https://github.com/chef-partners/chef-provisioning-vsphere/pull/48) ([jjasghar](https://github.com/jjasghar))
- Jenkinsfile for Jenkins BlueOcean [\#46](https://github.com/chef-partners/chef-provisioning-vsphere/pull/46) ([jjasghar](https://github.com/jjasghar))
- Initial examples directory [\#45](https://github.com/chef-partners/chef-provisioning-vsphere/pull/45) ([jjasghar](https://github.com/jjasghar))

## [v2.0.5](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.0.5) (2017-06-06)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v2.0.4...v2.0.5)

**Closed issues:**

- kitchen destroy not destroying machines [\#37](https://github.com/chef-partners/chef-provisioning-vsphere/issues/37)

**Merged pull requests:**

- @vm\_helper.ip is this global structure, which gets set to the current… [\#41](https://github.com/chef-partners/chef-provisioning-vsphere/pull/41) ([jjlimepoint](https://github.com/jjlimepoint))
- Handle blank guest IP address that generates multiple different errors. [\#38](https://github.com/chef-partners/chef-provisioning-vsphere/pull/38) ([Belogix](https://github.com/Belogix))

## [v2.0.4](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.0.4) (2017-05-24)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v2.0.3...v2.0.4)

**Merged pull requests:**

- Issue 35 [\#36](https://github.com/chef-partners/chef-provisioning-vsphere/pull/36) ([jcalonsoh](https://github.com/jcalonsoh))

## [v2.0.3](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.0.3) (2017-05-22)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v2.0.2...v2.0.3)

**Closed issues:**

- Patch on transport\_respond? [\#31](https://github.com/chef-partners/chef-provisioning-vsphere/issues/31)
- Github Templates [\#28](https://github.com/chef-partners/chef-provisioning-vsphere/issues/28)

**Merged pull requests:**

- Patch on transport\_respond? [\#32](https://github.com/chef-partners/chef-provisioning-vsphere/pull/32) ([jcalonsoh](https://github.com/jcalonsoh))
- Added github templates [\#30](https://github.com/chef-partners/chef-provisioning-vsphere/pull/30) ([jjasghar](https://github.com/jjasghar))
- waffle.io Badge [\#29](https://github.com/chef-partners/chef-provisioning-vsphere/pull/29) ([waffle-iron](https://github.com/waffle-iron))
- Time to do doc all the things! [\#27](https://github.com/chef-partners/chef-provisioning-vsphere/pull/27) ([jjasghar](https://github.com/jjasghar))

## [v2.0.2](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.0.2) (2017-05-13)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v2.0.0...v2.0.2)

**Closed issues:**

- datacenter not found error [\#23](https://github.com/chef-partners/chef-provisioning-vsphere/issues/23)

**Merged pull requests:**

- Enable to match regex [\#26](https://github.com/chef-partners/chef-provisioning-vsphere/pull/26) ([jcalonsoh](https://github.com/jcalonsoh))

## [v2.0.0](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v2.0.0) (2017-05-12)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v1.1.2...v2.0.0)

**Merged pull requests:**

- Traverse folders for dc \(issue \#23\) [\#24](https://github.com/chef-partners/chef-provisioning-vsphere/pull/24) ([danhiris](https://github.com/danhiris))
- allow chef13, since it works now [\#22](https://github.com/chef-partners/chef-provisioning-vsphere/pull/22) ([jjlimepoint](https://github.com/jjlimepoint))
- Wait for ipv4 enhancement v2 [\#21](https://github.com/chef-partners/chef-provisioning-vsphere/pull/21) ([jcalonsoh](https://github.com/jcalonsoh))

## [v1.1.2](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v1.1.2) (2017-05-08)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v1.1.1...v1.1.2)

**Merged pull requests:**

- 1.1.2 release [\#20](https://github.com/chef-partners/chef-provisioning-vsphere/pull/20) ([jjasghar](https://github.com/jjasghar))
- corrected winrm port assignment so it does not always equal 5986 [\#19](https://github.com/chef-partners/chef-provisioning-vsphere/pull/19) ([tuccimon](https://github.com/tuccimon))
- Update README to cover multi-nodes in kitchen.yml [\#18](https://github.com/chef-partners/chef-provisioning-vsphere/pull/18) ([michaeltlombardi](https://github.com/michaeltlombardi))
- Revert "Wait for ipv4 enhancement" [\#16](https://github.com/chef-partners/chef-provisioning-vsphere/pull/16) ([jjasghar](https://github.com/jjasghar))
- Wait for ipv4 enhancement [\#14](https://github.com/chef-partners/chef-provisioning-vsphere/pull/14) ([jcalonsoh](https://github.com/jcalonsoh))

## [v1.1.1](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v1.1.1) (2017-04-20)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v1.1.0...v1.1.1)

**Merged pull requests:**

- rubocop'd [\#12](https://github.com/chef-partners/chef-provisioning-vsphere/pull/12) ([jjasghar](https://github.com/jjasghar))

## [v1.1.0](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v1.1.0) (2017-04-20)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v1.0.0...v1.1.0)

**Closed issues:**

- Skip bootstrap after provisioning [\#6](https://github.com/chef-partners/chef-provisioning-vsphere/issues/6)

**Merged pull requests:**

- document reqd fields for sysprep [\#11](https://github.com/chef-partners/chef-provisioning-vsphere/pull/11) ([nealbrown](https://github.com/nealbrown))
- Updated some depenant gems [\#10](https://github.com/chef-partners/chef-provisioning-vsphere/pull/10) ([jjasghar](https://github.com/jjasghar))
- Metalseargolid feature/ipv4 bootstrap [\#8](https://github.com/chef-partners/chef-provisioning-vsphere/pull/8) ([jjasghar](https://github.com/jjasghar))
- Add proxy support [\#7](https://github.com/chef-partners/chef-provisioning-vsphere/pull/7) ([jjasghar](https://github.com/jjasghar))

## [v1.0.0](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v1.0.0) (2017-04-17)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.8.1...v1.0.0)

**Merged pull requests:**

- v1.0.0 release [\#4](https://github.com/chef-partners/chef-provisioning-vsphere/pull/4) ([jjasghar](https://github.com/jjasghar))
- Added links to the README [\#3](https://github.com/chef-partners/chef-provisioning-vsphere/pull/3) ([jjasghar](https://github.com/jjasghar))
- Cleanup for new release [\#2](https://github.com/chef-partners/chef-provisioning-vsphere/pull/2) ([jjasghar](https://github.com/jjasghar))
- ensure machine\_options and configs are symbolised for chef13 [\#1](https://github.com/chef-partners/chef-provisioning-vsphere/pull/1) ([jjlimepoint](https://github.com/jjlimepoint))

## [v0.8.1](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.8.1) (2015-08-25)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.8.0...v0.8.1)

## [v0.8.0](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.8.0) (2015-08-20)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.7.2...v0.8.0)

## [v0.7.2](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.7.2) (2015-08-19)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.7.1...v0.7.2)

## [v0.7.1](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.7.1) (2015-07-27)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.7.0...v0.7.1)

## [v0.7.0](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.7.0) (2015-07-21)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.6.0...v0.7.0)

## [v0.6.0](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.6.0) (2015-07-01)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.6.0.dev.1...v0.6.0)

## [v0.6.0.dev.1](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.6.0.dev.1) (2015-06-28)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.8...v0.6.0.dev.1)

## [v0.5.8](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.8) (2015-06-19)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.7.dev6...v0.5.8)

## [v0.5.7.dev6](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.7.dev6) (2015-06-15)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.7.dev5...v0.5.7.dev6)

## [v0.5.7.dev5](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.7.dev5) (2015-06-14)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.7.dev4...v0.5.7.dev5)

## [v0.5.7.dev4](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.7.dev4) (2015-06-14)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.7.dev3...v0.5.7.dev4)

## [v0.5.7.dev3](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.7.dev3) (2015-06-14)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.7.dev2...v0.5.7.dev3)

## [v0.5.7.dev2](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.7.dev2) (2015-06-13)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.7.dev1...v0.5.7.dev2)

## [v0.5.7.dev1](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.7.dev1) (2015-06-13)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.7.dev...v0.5.7.dev1)

## [v0.5.7.dev](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.7.dev) (2015-06-13)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.7...v0.5.7.dev)

## [v0.5.7](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.7) (2015-06-09)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.6...v0.5.7)

## [v0.5.6](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.6) (2015-06-09)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.5...v0.5.6)

## [v0.5.5](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.5) (2015-05-29)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.4...v0.5.5)

## [v0.5.4](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.4) (2015-05-27)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.3...v0.5.4)

## [v0.5.3](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.3) (2015-05-20)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.1...v0.5.3)

## [v0.5.1](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.1) (2015-05-20)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.5.0...v0.5.1)

## [v0.5.0](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.5.0) (2015-05-16)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.4.2...v0.5.0)

## [v0.4.2](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.4.2) (2015-04-27)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.4.1...v0.4.2)

## [v0.4.1](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.4.1) (2015-04-25)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.4.0...v0.4.1)

## [v0.4.0](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.4.0) (2015-04-23)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.3.77...v0.4.0)

## [v0.3.77](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.3.77) (2015-04-18)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.3.76...v0.3.77)

## [v0.3.76](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.3.76) (2015-03-18)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.3.75...v0.3.76)

## [v0.3.75](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.3.75) (2015-03-06)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.3.74...v0.3.75)

## [v0.3.74](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.3.74) (2015-03-04)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.3.73...v0.3.74)

## [v0.3.73](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.3.73) (2015-02-13)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.2.0...v0.3.73)

## [v0.2.0](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.2.0) (2014-05-22)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.1.4...v0.2.0)

## [v0.1.4](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.1.4) (2014-05-10)
[Full Changelog](https://github.com/chef-partners/chef-provisioning-vsphere/compare/v0.1.3...v0.1.4)

## [v0.1.3](https://github.com/chef-partners/chef-provisioning-vsphere/tree/v0.1.3) (2014-05-09)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
