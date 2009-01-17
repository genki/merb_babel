# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{merb_babel}
  s.version = "0.1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Aimonetti"]
  s.date = %q{2009-01-18}
  s.description = %q{Merb plugin that provides simple localization/internationalisation}
  s.email = %q{mattaimonetti@gmail.com}
  s.extra_rdoc_files = ["README.markdown", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README.markdown", "Rakefile", "TODO", "lib/merb_babel", "lib/merb_babel/locale_detector.rb", "lib/merb_babel/m_i18n.rb", "lib/merb_babel/m_l10n.rb", "lib/merb_babel/m_locale.rb", "lib/merb_babel/merbtasks.rb", "lib/merb_babel.rb", "spec/lang", "spec/lang/en-UK.yml", "spec/lang/en-US.yml", "spec/lang/en.yml", "spec/lang/ja.yml", "spec/locale_detector_spec.rb", "spec/m_i18n_spec.rb", "spec/m_l10n_spec.rb", "spec/merb_babel_spec.rb", "spec/other_lang_dir", "spec/other_lang_dir/fr.yml", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/mattetti/merb_babel/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{merb}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Merb plugin that provides simple localization/internationalisation}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<merb-core>, [">= 1.0"])
      s.add_runtime_dependency(%q<locale>, [">= 0.9.0"])
    else
      s.add_dependency(%q<merb-core>, [">= 1.0"])
      s.add_dependency(%q<locale>, [">= 0.9.0"])
    end
  else
    s.add_dependency(%q<merb-core>, [">= 1.0"])
    s.add_dependency(%q<locale>, [">= 0.9.0"])
  end
end
