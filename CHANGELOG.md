# Changelog

## v1.2.4 - 2026-01-20
* Simplify exported outputs to improve structure and clarity.

## v1.2.3 - 2026-01-19
* Fix `for_each` fallback to use `toset([])` for certificates and groups.

## v1.2.2 - 2026-01-16
* Add outputs for the resources created.

## v1.2.1 - 2024-04-30
* Make description field in APIs and Products optional.
* Fix logic error in product policy resource introduced in v1.2.0.
* Using `try()` instead of conditional `can()` in arguments.

## v1.2.0 - 2024-04-26
* Added option to fallback to default policy filename (`policy.xml`), if custom policy filename doesn't exist. This can be useful if custom policy filename is used to differentiate between runtime environments, but in some APIs or products the policy should be the same in all runtime environments. In this case, you then only need to configure one `policy.xml`.

## v1.1.0 - 2024-03-25
* Add support for configuring custom filenames in the artifacts folder. This can, for example, be used to differentiate between runtime environments.

## v1.0.0 - 2023-05-23
* Initial version