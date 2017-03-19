# WCForms
WCForms is a dynamic framework written in Swift to create forms on iOS. It is currently in development and is not recommended for use.

## Introduction

### What is a form?
A form is any view that shows details of an object using fields. Fields typically have a field name, a type, and an associated value. Forms can be in two different modes: read-only mode, where the user can see the value of the field, and edit mode, where the user can change the value of the fields and submit or save the form.

### Why a framework?
Forms are complex, from both a user perspective and a development one. They take a lot of time to get right. And yet many interactions are common and can be standardized. This framework is an attempt to create a reusable set of form fields and a standard form controller, while still maintaining the flexibility for developers to write their own form fields when input of custom data is required.

## Features

The following is a planned feature list that will be included in the 1.0 release. Completed items 

- [x] Subclassable form controller that supports read-only and edit modes
- [-] Form field types
-- [x] Text field
-- [x] Boolean (yes/no) field
-- [x] Integer field
-- [x] Date field
-- [ ] Email field
-- [ ] Text Area field
-- [ ] Decimal number field
-- [ ] Phone field
-- [ ] Option field
-- [ ] Multi-option field
-- [ ] Button field
-- [ ] Password field
-- [ ] Time field
-- [ ] Date & Time field
-- [ ] Time Interval field
-- [ ] Single Checkbox field
-- [ ] Currency field
-- [ ] Web Address field
- [-] Common appearances for fields
-- [x] Right Detail
-- [x] Stacked
-- [x] Stacked Caption
-- [ ] Left Detail
- [x] Ability to make fields read-only when the form is editable
- [x] Keyboard accessory for navigating between fields
- [ ] Accessibility
