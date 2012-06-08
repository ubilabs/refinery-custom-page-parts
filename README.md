refinery-custom-page-parts
==========================

Custom page parts for refinery.

Built for our own website, this refinery engine allows you to
define custom page parts that you can then add to refinery pages.

A custom page part is a sub-template that can be rendered instead of the
default text-only page part.

These sub-templates can have parameters that can are assigned and
administered through the refinery backend. A custom form is displayed to
fill these out instead of the usual simple wysiwyg editor. Currently,
you can define string, image or html parameters.

## Usage

1. Copy the `custom_page_parts` folder in your `vendor/engines` folder
2. Create a file named `custom_page_parts_config.rb` in your `config`
   folder
3. Define what parameters your custom page parts will have. For example,
   our `project` page part definition looks like this:

   ```ruby
      Refinery::CustomPageParts::define_page_part :identifier => :project do |p|
         p.field :project_sub_heading, :string
         p.field :project_photo, :image
         p.field :project_description, :html
         p.field :project_info_box, :html
         p.field :project_thumb, :image
         p.field :project_app_store_link, :string
      end
   ```
   
   You need to specify an identifier for the page part, and the name and
   type of each dynamic parameter it has.

   Parameter names need to be unique across *all* page part types. A nice
   way to work around this is to prepend the page part identifier to each
   of them.

4. Make sure adding new page parts is enabled in the refinery settings,
   then add a new page part.

   In the dialog that pops up, there is a select box you can use to insert
   one of the custom page parts you defined.

5. Edit the parameters value in the generated form, then save the page
6. Write a template that will be used to render each page part. You do
   this by adding a partial to the `views/custom_page_parts` folder.

   The partial name must be the part identifier you chose. Inside the
   partial, you can access the parameter values with `part.parameter`

   For example, here is a stripped down version of our project part
   partial:

   ```haml
     %section
       %article
         = image_tag Image.find_by_id(part.project_photo).url unless part.project_photo.blank?

     %header
       %h2
         = @page.title
       %h3
         = part.project_sub_heading.html_safe

     = part.project_description.html_safe
     = part.project_info_box.html_safe

     - unless part.project_app_store_link.blank?
      %a{:href => part.project_app_store_link}
   ```

## About

Developed at [ubilabs](http://www.ubilabs.net). 

Our website itself is a great example of what can be done with this engine.

