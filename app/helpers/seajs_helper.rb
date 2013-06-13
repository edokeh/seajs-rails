module SeajsHelper

  # get module name
  def seajs_modules(*modules)
    seajs_config = Rails.application.config.seajs

    modules.map! do |m|
      if m.start_with? '#'
        m[1..-1]
      else
        if seajs_config.compiled?
          seajs_config.family + '/' + m
        else
          '/assets/' + m
        end
      end
    end
    modules.to_s.html_safe
  end

  # generate seajs.use()
  def seajs_use(*modules)
    html = <<-html
    <script>
    seajs.use(#{seajs_modules(*modules)})
    </script>
    html

    html.html_safe
  end

  # include seajs script and map config
  def seajs_tag
    seajs_config = Rails.application.config.seajs

    html = <<-html
      <script src="/assets/sea-modules/#{seajs_config.seajs_path}"></script>
      <script>
      seajs.config({
        map: #{seajs_config.map_json || '[]'}
      })
      </script>
    html

    html.html_safe
  end
end
