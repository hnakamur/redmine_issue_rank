Redmine Issue Rank plugin
=========================

This is a plugin for renumbering issue ranks automatically.
[Japanese readme](README.ja.md)

## Supported redmine and ruby version

* Tested with Redmine 2.4.1 and Ruby 1.9.3-p551
* Maybe other versions will be supported in the future

## Configurations after installing this plugin

* In plugin config, set custom field name for rank (ex. "Rank").
* Create an integer custom field for issue ranks with the same name as above.
* Add permission "Renumber ranks with display orders" in "Issue Rank" to appropriate roles
* In per-project settings, select "Issue Rank" in "Modules" tab.
* In issues page, create a custom query.
    * Sort by the rank field ascending
    * Include the rank field into selected columns
    * Adjust other settings as you like. My suggestion is:
       * Visible to any users.
       * For all projects.

## Usage

* When you save an issue, ranks of all issues in the project will be adjusted automatically.
* In the issues page, you can update ranks of all issues in the project with display orders by clicking "Update issue ranks with current sort order" menu in the side bar.
* You can manually edit the rank of an issue at the issue edit page.
   * When you save the issue, ranks of all issues in the project will be adjusted.
* When you change the status of an issue from open to closed or from closed to open, the rank of the issue will be set to the next to the maximum rank of open issues, and then ranks of all issues in the project will be adjusted.

## License

MIT
