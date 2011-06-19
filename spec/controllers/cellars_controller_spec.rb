require 'spec_helper'

def mock_file_upload(file_name)
  full_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'cellar_import', file_name))

  uploader = mock(Object, :original_path => full_path, :content_type => 'text/csv')
  tempfile_mock = mock(Object, :path => full_path)
  uploader.stub(:tempfile).and_return(tempfile_mock)

  def uploader.read
    File.read(original_path)
  end

  def uploader.size
    File.stat(original_path).size
  end

  uploader
end

describe CellarsController do
  describe '#invalid_import_columns' do
    it 'should not reject any beer column names besides the pretermined rejected ones' do
      controller.invalid_import_columns(Beer.importable_column_names).should be_empty
    end

    it 'should reject anything in the predetermined reject list' do
      columns = Beer.importable_column_names + ['id']
      controller.invalid_import_columns(columns).should_not be_empty
    end

    it 'should reject anything else' do
      columns = Beer.importable_column_names + ['poo']
      controller.invalid_import_columns(columns).should_not be_empty
    end
  end

  describe '#validate_import_columns' do
    it 'should return nil if all columns are valid' do
      columns = ['Cellared At', 'Name']
      controller.validate_import_columns(columns).should be_nil
    end

    it 'should return the invalid column' do
      columns = ['LOL!', 'Name']
      controller.validate_import_columns(columns).should  == ['LOL!']
    end
  end

  describe '#import' do
    before do
      u = create_user(:username => 'trololo', :email =>'lol@lololol.com', :confirmed => true)
      create_cellar(:user => u)

      sign_in_as(u)
    end

    it 'should import CSV data to cellars' do
      lambda {
        post :import, :id => 'trololo', :import_file => mock_file_upload('valid_beers.csv')
      }.should change(Beer, :count)
    end

    it 'should redirect to invalid_columns if there were bad column names' do
      post :import, :id => 'trololo', :import_file => mock_file_upload('bad_column.csv')
      response.should render_template('cellars/import/invalid_column')
    end
  end
end
