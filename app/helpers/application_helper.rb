# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def title(page_title)
    content_for(:title) { page_title }
  end

  def head(html_head)
    content_for(:head) { html_head }
  end

  # nested attribute helpers from Ryan Bates:
  def remove_child_link(name, f)
    # name = delete_no_alt_icon + " " + name
    # deprecated _delete, use _destroy instead
    # f.hidden_field(:_delete) + link_to_function(name, "remove_fields(this)")
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def add_child_link(name, f, method)
    fields = new_child_fields(f, method)
    # name = add_no_alt_icon + " " + name
    link_to_function(name, h("insert_fields(this, \"#{method}\", \"#{escape_javascript(fields)}\")"))
  end

  def new_child_fields(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f
    form_builder.fields_for(method, options[:object], :child_index => "new_#{method}") do |f|
      render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
    end
  end

  # above nested attribute helpers, adapted for widgets
  def add_widget_child_link(name, f, method)
    fields = new_widget_child_fields(f, method)
    # name = add_no_alt_icon + " " + name
    link_to_function(name, h("insert_fields(this, \"#{method}\", \"#{escape_javascript(fields)}\")"))
  end

  def new_widget_child_fields(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:view] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f
    form_builder.fields_for(method, options[:object], :child_index => "new_#{method}") do |f|
      render(:view => options[:view], :locals => { options[:form_builder_local] => f })
    end
  end

  def add_errors(original_message, error_message)
    original_message += error_message
  end

  # Warning: This is significantly different from the version in edge
  # If/when the Rails version is updated this might bork
  def flash_error_messages_for(*params)
    options = params.extract_options!.symbolize_keys

    if object = options.delete(:object)
      objects = [object].flatten
    else
      objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
    end

    objects.compact!

    count = objects.inject(0) {|sum, object| sum + object.errors.count }
    unless count.zero?
      I18n.with_options :locale => options[:locale], :scope => [:activerecord, :errors, :template] do |locale|
        error_messages = objects.sum {|object| object.errors.full_messages.map {|msg| content_tag(:li, ERB::Util.html_escape(msg)) } }.join
        @template.content_for :form_errors, " due to the following error#{'s' if count > 1}: #{@template.content_tag(:ul, error_messages)}"
      end
    end
  end
end
