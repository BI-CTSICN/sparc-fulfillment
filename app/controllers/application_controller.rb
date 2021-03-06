# Copyright © 2011-2017 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :authenticate_identity!
  before_filter :breadcrumbs
  around_filter :set_time_zone, if: :identity_signed_in?
  before_filter :push_user_to_gon, if: :identity_signed_in?

  def set_time_zone(&block)
    time_zone = current_identity.time_zone
    Time.use_zone(time_zone, &block)
  end

  def authorize_protocol
    unless current_identity.protocols.include? @protocol
      flash[:alert] = t(:protocol)[:flash_messages][:unauthorized]
      redirect_to root_path
    end
  end

  def user_for_paper_trail
    identity_signed_in? ? current_identity.id : 'Unauthenticated User'
  end

  def push_user_to_gon
    gon.push({current_identity_id: current_identity.id})
  end

  private

  def breadcrumbs
    session[:breadcrumbs] ||= []

    referrer = request.env['HTTP_REFERER']
    referrer = referrer.split('?').first if referrer # take off the GET parameters unless nil

    request_url = request.original_url
    request_url = request_url.split('?').first if request_url # take off the GET parameters unless nil

    # add to history if we are not going back, request is html, it's not the sign in page, and we aren't going to the same page that we are currently on
    # The Iowa Shibboleth referrer is /idp/profile/SAML2/Redirect/SSO?back=true so we added "SAML2" to the list of referrer's to exclude.
    if !params[:back] && request.format.to_sym === :html && (referrer && referrer.exclude?('sign_in') && referrer.exclude?('shibboleth') && referrer.exclude?('SAML2')) && referrer != request_url
      session[:breadcrumbs].push(referrer)
    elsif params[:back]
      session[:breadcrumbs].pop # remove last element if we are going back
    end
  end
end
