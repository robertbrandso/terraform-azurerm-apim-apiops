# Changelog
## v1.2.0 - 2024-04-26
* Added option to fallback to default policy filename (`policy.xml`), if custom policy filename doesn't exist. This can be useful if custom policy filename is used to differentiate between runtime environments, but in some APIs or products the policy should be the same in all runtime environments. In this case, you then only need to configure one `policy.xml`.

## v1.1.0 - 2024-03-25
* Add support for configuring custom filenames in the artifacts folder. This can, for example, be used to differentiate between runtime environments.

## v1.0.0 - 2023-05-23
* Initial version