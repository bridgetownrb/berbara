# 👑 Serbea: Similar to ERB, Except Awesomer

The Ruby template language you've always dreamed of is finally here. _Le roi est mort, vive le roi!_

Serbea combines the best ideas from "brace-style" template languages such as Liquid, Nunjucks, Twig, Jinja, Mustache, etc.—and applies them to the world of ERB. You can use Serbea in Rails applications, Bridgetown static sites, or pretty much any Ruby scenario you could imagine.

## Features

* Real Ruby. Like, for real.
* Filters!!! Pipeline operators!!!
* Autoescaped variables by default within the pipeline (`{{ }}`) tags. Use the `safe`/`raw` or `escape`/`h` filters to control escaping on output.
* Render directive `{%@ %}` as shortcut for rendering either string-named partials (`render "tmpl"`) or object instances (`render MyComponent.new`).
* Supports every convention of ERB and builds upon it with new features (which is why it's "awesomer!").
* Builtin frontmatter support so you can access the variables written into the top YAML within your templates. In any Rails view, including layouts, you'll have access to the `@frontmatter` ivar which is a merged `HashWithDotAccess::Hash` with data from any part of the view tree (partials, pages, layout).
* The filters accessible within Serbea templates are either helpers (where the variable gets passed as the first argument) or instance methods of the variable itself, so you can build extremely expressive pipelines that take advantage of the code you already know and love. (For example, in Rails you could write `{{ "My Link" | link_to: route_path }}`).
* The `Serbea::Pipeline.exec` method lets you pass a pipeline template in, along with an optional input value or included helpers module, and you'll get the output as a object of any type (not converted to a string like in traditional templates). For example: `Serbea::Pipeline.exec("[1,2,3] |> map: ->(i) { i * 10 }")` will return `[10, 20, 30]`.

## What It Looks Like

```hbs
# example.serb

{% wow = capture do %}
  This is {{ "amazing" + "!" | upcase }}
{% end.each_char.reduce("") do |newstr, c|
    newstr += " #{c}"
   end.strip %}

{{ wow | prepend: "OMG! " }}
```

```hbs
<p>
  {%
    helper :multiply_array do |input, multiply_by = 2|
      input.map do |i|
        i.to_i * multiply_by
      end
    end
  %}

  Multiply! {{ [1,3,6, "9"] | multiply_array: 10 }}
</p>
```

```hbs
{%= form classname: "checkout" do |f| %}
  {{ f.input :first_name, required: true | errors: error_messages }}
{% end %}
```

```hbs
{%= render "box" do %}
  This is **dope!**
  {%= render "card", title: "Nifty!" do %}
    So great.
  {% end %}
{% end %}

# Let's simplify that using the new render directive!

{%@ "box" do %}
  This is **dope!**
  {%@ "card", title: "Nifty!" do %}
    So great.
  {% end %}
{% end %}
```

```hbs
# Works with ViewComponent!

{%= render(Theme::DropdownComponent.new(name: "banner", label: "Banners")) do |dropdown| %}
  {% RegistryTheme::BANNERS.each do |banner| %}
    {% dropdown.slot(:item, value: banner) do %}
      <img src="{{ banner | parameterize: separator: "_" | prepend: "/themes/" | append: ".jpg" }}">
      <strong>{{ banner }}</strong>
    {% end %}
  {% end %}
{% end %}

# Even better, use the new render directive!

{%@ Theme::DropdownComponent name: "banner", label: "Banners" do |dropdown| %}
  {% RegistryTheme::BANNERS.each do |banner| %}
    {% dropdown.slot(:item, value: banner) do %}
      <img src="{{ banner | parameterize: separator: "_" | prepend: "/themes/" | append: ".jpg" }}">
      <strong>{{ banner }}</strong>
    {% end %}
  {% end %}
{% end %}
```

```hbs
# The | and |> pipeline operators are equivalent, so you can write like this if you want!

{{
  [1,2,3] |>
  map: -> i  {
    i * 10
  } |>
  filter: -> i do
    i > 15
  end |>
  assign_to: :array_length
}}

Array length: {{ @array_length.length }}
```
