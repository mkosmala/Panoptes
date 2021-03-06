shared_examples "is showable" do
  before(:each) do
    default_request scopes: scopes, user_id: authorized_user.id
    get :show, id: resource.id
  end

  it 'should return 200' do
    expect(response.status).to eq 200
  end

  it 'should return the requested resource' do
    expect(json_response[api_resource_name].length).to eq 1
  end

  it_behaves_like 'an api response'
end
