class StyleGuide
  attr_reader :violations

  def initialize
    @violations = []
  end

  def check(lines)
    config = YAML.load_file(File.expand_path('../../../.rubocop.yml', __FILE__))
    tokens, sexp, correlations = Rubocop::CLI.rip_source(lines)

    Rubocop::Cop::Cop.all.each do |cop_klass|
      cop_name = cop_klass.name.split('::').last
      cop_config = config[cop_name]

      if cop_config.nil? || cop_config['Enabled']
        cop_klass.config = cop_config
        cop = cop_klass.new
        cop.correlations = correlations
        cop.inspect('hound', lines, tokens, sexp)

        @violations += cop.offences
      end
    end
  end
end
