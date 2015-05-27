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
* Add permission "Renumber ranks with display orders" in "Issue Rank" to appropriate roles.
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
   1. Ranks of visible issues are higher than invisible ones
   2. Ranks of visible issues are set by display orders
   3. Ranks of invisible issues are ordered by issue ranks
   4. Ranks of same rank issues are ordered by issue IDs.
* You can manually edit the rank of an issue at the issue edit page.
   * When you save the issue, ranks of all issues in the project will be adjusted.
   * Among issues which have the same rank, the issue you editted will have 
     the highest rank, and other issues follows.
   * Ranks are renumbered starting with 1. So the rank of issues may become
     the diffent value than you input on the issue edit page.
* When you change the status of an issue from open to closed or from closed to open, the rank of the issue will be set to the next to the maximum rank of open issues, and then ranks of all issues in the project will be adjusted.

## License

MIT
