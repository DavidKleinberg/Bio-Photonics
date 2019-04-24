# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""This is a web server API implemented using Google Cloud
Endpoints."""

# [START imports]
import endpoints
from endpoints import message_types
from endpoints import messages
from endpoints import remote

import logging
logging.getLogger('endpoints').setLevel(logging.DEBUG)
logging.getLogger('endpoints_management').setLevel(logging.DEBUG)

# import dataProcessing as algo

# [END imports]

api_collection = endpoints.api(name='melanoma', version='v1.0')

# [START messages]
class MelanomaRequest(messages.Message):
    connect = messages.StringField(1)
    message = messages.StringField(1)


class MelanomaResponse(messages.Message):
    """A proto Message that contains a simple string field."""
    message = messages.StringField(1)


MELANOMA_RESOURCE = endpoints.ResourceContainer(
    MelanomaRequest,
    n=messages.IntegerField(2, default=1))
# [END messages]


# [START echo_api_class]
@api_collection.api_class(resource_name='upload')
#@endpoints.api(name='upload', version='v1')
class DataUpload(remote.Service):

    # [START echo_api_method]
    @endpoints.method(
        # This method takes a ResourceContainer defined above.
        MELANOMA_RESOURCE,
        # This method returns an Echo message.
        MelanomaResponse,
        path='upload',
        http_method='POST',
        name='upload_fcn')
    def upload_fcn(self, request):
        output_message = ' '.join([request.message] * request.n)
        return MelanomaResponse(message=output_message)
    # [END echo_api_method]

    @endpoints.method(
        # This method takes an empty request body.
        message_types.VoidMessage,
        # This method returns an Echo message.
        MelanomaResponse,
        path='upload/connect',
        http_method='GET',
        # Require auth tokens to have the following scopes to access this API.
        scopes=[endpoints.EMAIL_SCOPE],
        # OAuth2 audiences allowed in incoming tokens.
        audiences=['your-oauth-client-id.com'],
        allowed_client_ids=['your-oauth-client-id.com'])
    def get_user_email(self, request):
        user = endpoints.get_current_user()
        # If there's no user defined, the request was unauthenticated, so we
        # raise 401 Unauthorized.
        if not user:
            raise endpoints.UnauthorizedException
        return EchoResponse(message=user.email())
# [END echo_api_class]


# [START data_process_api]
@api_collection.api_class(resource_name='process')
#@endpoints.api(name='process', version='v1')
class DataProcess(remote.Service):

    # [START echo_api_method]
    @endpoints.method(
        # This method takes a ResourceContainer defined above.
        MELANOMA_RESOURCE,

        # This method returns an Echo message.
        MelanomaResponse,
        path='process',
        http_method='POST',
        name='process_data')

    def process_data(self, request):
        output_message = ' '.join([request.message] * request.n)
        return MelanomaResponse(message=output_message)
# [END data_process_api]


# [START data_results_api]
@api_collection.api_class(resource_name='results')
#@endpoints.api(name='results', version='v1')
class MelanomaResults(remote.Service):

    # [START echo_api_method]
    @endpoints.method(
        # This method takes a ResourceContainer defined above.
        MELANOMA_RESOURCE,

        # This method returns an Echo message.
        MelanomaResponse,
        path='diagnostic',
        http_method='POST',
        name='get_diagnostic')
    def get_diagnostic(self, request):
        output_message = ' '.join([request.message] * request.n)
        return MelanomaResponse(message=output_message)
# [END data_process_api]


# [START api_server]
api = endpoints.api_server([api_collection])
# [END api_server]
