# frozen_string_literal: true

class Eg027PermissionsChangeSingleSettingController < EgController
  include ApiCreator
  def get
     args = {
      account_id: session['ds_account_id'],
      base_path: session['ds_base_path'],
      access_token: session['ds_access_token']
    }
    accounts_api = create_account_api(args)
    permissions = accounts_api.list_permissions(args[:account_id],  options = DocuSign_eSign::ListPermissionsOptions.default)
    @permissions_lists = permissions.permission_profiles
    super
  end

  def create
    minimum_buffer_min = 3
    if check_token(minimum_buffer_min)
    begin  
        results  = ::Eg027Service.new(session, request).call
        # Step 4. a) Call the eSignature API
        #         b) Display the JSON response  
        @title = 'Changing a setting in an existing permission profile'
        @h1 = ' Changing a setting in an existing permission profile'
        @message = "Existing permission profile was changed"
        @json = results.to_json.to_json
        render 'ds_common/example_done'

      rescue DocuSign_eSign::ApiError => e
        error = JSON.parse e.response_body
        @error_code = error['errorCode']
        @error_message = error['message']
        render 'ds_common/error'
      end
    else
      flash[:messages] = 'Sorry, you need to re-authenticate.'
      # We could store the parameters of the requested operation so it could be restarted
      # automatically. But since it should be rare to have a token issue here,
      # we'll make the user re-enter the form data after authentication
      redirect_to '/'
    end
  end
end
