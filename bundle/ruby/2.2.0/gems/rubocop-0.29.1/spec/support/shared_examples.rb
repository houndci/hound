# encoding: utf-8

# `cop` and `source` must be declared with #let.

shared_examples_for 'accepts' do
  it 'accepts' do
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end
end

shared_examples_for 'mimics MRI 2.1' do |grep_mri_warning|
  if RUBY_ENGINE == 'ruby' && RUBY_VERSION.start_with?('2.1')
    it "mimics MRI #{RUBY_VERSION} built-in syntax checking" do
      inspect_source(cop, source)
      offenses_by_mri = MRISyntaxChecker.offenses_for_source(
        source, cop.name, grep_mri_warning
      )

      # Compare objects before comparing counts for clear failure output.
      cop.offenses.each_with_index do |offense_by_cop, index|
        offense_by_mri = offenses_by_mri[index]
        # Exclude column attribute since MRI does not
        # output column number.
        [:severity, :line, :cop_name].each do |a|
          expect(offense_by_cop.send(a)).to eq(offense_by_mri.send(a))
        end
      end

      expect(cop.offenses.count).to eq(offenses_by_mri.count)
    end
  end
end

shared_examples_for 'misaligned' do |prefix, alignment_base, arg, end_kw, name|
  name ||= alignment_base
  it "registers an offense for mismatched #{name} ... end" do
    inspect_source(cop, ["#{prefix}#{alignment_base} #{arg}",
                         end_kw])
    expect(cop.offenses.size).to eq(1)
    regexp = /`end` at 2, \d+ is not aligned with `#{alignment_base}` at 1,/
    expect(cop.messages.first).to match(regexp)
    expect(cop.highlights.first).to eq('end')
    expect(cop.config_to_allow_offenses).to eq('AlignWith' => opposite)
  end
end

shared_examples_for 'aligned' do |alignment_base, arg, end_kw, name|
  name ||= alignment_base
  it "accepts matching #{name} ... end" do
    inspect_source(cop, ["#{alignment_base} #{arg}",
                         end_kw])
    expect(cop.offenses).to be_empty
  end
end
