require 'test/unit'
require 'git_external'

class GitExternalTest < Test::Unit::TestCase
  def test_usage
    git_external = GitExternal.new
    assert_respond_to git_external, :usage
  end

  def test_parse_configuration
    git_external = GitExternal.new

    path   = 'mycustompath'
    url    = 'git://git.server.com/my-custom-project.git'
    branch = 'master'

    config = [
      "external.mycustompath.path=#{path}",
      "external.mycustompath.url=#{url}",
      "external.mycustompath.branch=#{branch}"
    ]

    expected = {
      'mycustompath' => {
        'path'   => path,
        'url'    => url,
        'branch' => branch
      }
    }

    configurations = git_external.parse_configuration config

    assert_equal expected, configurations
  end
end
