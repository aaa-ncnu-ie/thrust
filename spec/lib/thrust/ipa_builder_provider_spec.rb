require 'spec_helper'

describe Thrust::IPABuilderProvider do
  describe "#instance" do
    let(:app_config) do
      Thrust::AppConfig.new(
        'app_name' => 'AppName',
        'distribution_certificate' => 'signing_identity',
        'project_name' => 'project_name',
        'workspace_name' => 'workspace_name',
        'build_directory' => 'build_dir'
      )
    end

    let(:distribution_config) do
      Thrust::DeploymentTarget.new(
        'notify' => 'true',
        'distribution_list' => 'devs',
        'build_configuration' => 'configuration',
        'provisioning_search_query' => 'Provisioning Profile query',
        'note_generation_method' => 'autotag'
      )
    end

    let(:deployment_target) { 'production' }

    let(:xcode_tools_provider) { double(Thrust::XcodeToolsProvider) }
    let(:xcode_tools) { double(Thrust::XcodeTools) }
    let(:agv_tool) { double(Thrust::AgvTool) }
    let(:git) { double(Thrust::Git) }
    let(:executor) { double(Thrust::Executor) }

    subject(:provider) { Thrust::IPABuilderProvider.new }

    before do
      allow(Thrust::XcodeTools).to receive(:new).and_return(xcode_tools)
      allow(Thrust::AgvTool).to receive(:new).and_return(agv_tool)
      allow(Thrust::Git).to receive(:new).and_return(git)
      allow(Thrust::Executor).to receive(:new).and_return(executor)
    end

    it 'builds the dependencies and passes provisioning search query, thrust config, and distribution_config to the Thrust::Deploy' do
      expect(Thrust::XcodeToolsProvider).to receive(:new).and_return(xcode_tools_provider)
      expect(xcode_tools_provider).to receive(:instance).with($stdout, 'configuration', 'build_dir', {project_name: 'project_name', workspace_name: 'workspace_name'}).and_return(xcode_tools)
      expect(Thrust::Git).to receive(:new).with($stdout, executor).and_return(git)
      expect(Thrust::AgvTool).to receive(:new).with(executor, git).and_return(agv_tool)

      expect(Thrust::IPABuilder).to receive(:new).with($stdout, xcode_tools, agv_tool, git, app_config, distribution_config, deployment_target).and_call_original

      expect(provider.instance(app_config, distribution_config, deployment_target)).to be_instance_of(Thrust::IPABuilder)
    end
  end
end
