include_recipe 'jenkins::install_sm_ext'
include_recipe 'jenkins::install'
include_recipe 'jenkins::configure'
include_recipe 'jenkins::restart'
