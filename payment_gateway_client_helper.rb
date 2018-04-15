module PaymentGatewayClientHelper
	require 'net/http'
	require 'digest'
	require "openssl"                                                                                                                                                                                           
	require "base64"                                                                                                                                                                                            
	                                                                                                                                                                                                            
	include Base64 

	KEY = 'Q9fbkBF8au24C9wshGRW9ut8ecYpyXye5vhFLtHFdGjRg3a4HxPYRfQaKutZx5N4'
	class Request
		def initialize(params)
			@bank_ifsc_code = params[:bank_ifsc_code]
			@bank_account_number = params[:bank_account_number]
			@amount = params[:amount]
			@merchant_transaction_ref = params[:merchant_transaction_ref]
			@transaction_date = params[:transaction_date]
			@payment_gateway_merchant_reference = params[:payment_gateway_merchant_reference]
		end

		def convert_params_to_string
			"bank_ifsc_code=#{@bank_ifsc_code}|bank_account_number=#{@bank_account_number}|amount=#{@amount}|merchant_transaction_ref=#{@merchant_transaction_ref}|transaction_date=#{@transaction_date}|payment_gateway_merchant_reference=#{@payment_gateway_merchant_reference}"
		end

		def create_sha_1_digest(string)
			sha = Digest::SHA1.hexdigest string
		end

		def aes_128_encryption(payload_with_sha)
			cipher = OpenSSL::Cipher::AES128.new(:CBC)  
			cipher.key = PaymentGatewayClientHelper::KEY                                                                                                                                                               
			cipher.encrypt
			encrypted_payload = cipher.update(payload_with_sha)
		end


		def post_data
			payload = convert_params_to_string
			payload_with_sha = payload + "|hash=" + create_sha_1_digest(payload)
			payload_to_pg = Base64.urlsafe_encode64(aes_128_encryption(payload_with_sha))
			response_handler = PaymentGatewayClientHelper::Response.new
			response_handler.display_result(payload_to_pg)
			#post request to server
			#uri = URI('http://examplepg.com/new_transaction')
			#response = Net::HTTP.post_form(uri, 'msg' => payload_to_pg)
			#decrypt and decode response and display the final result
		end
	end

	class Response
		def convert_string_to_hash
		end

		def process_request(decrypted_payload)
			#it should check if request parameters are valid and then process the request
		end

		def aes_128_decryption(decoded_msg)
			cipher = OpenSSL::Cipher::AES128.new(:CBC)  
			cipher.key = PaymentGatewayClientHelper::KEY
			cipher.decrypt                                                                                                                                                               
			decrypted_payload = cipher.update(decoded_msg)
		end

		def display_result(msg)
			decrypted_payload = aes_128_decryption(Base64.urlsafe_decode64(msg))
			process_request(decrypted_payload)
			#convert response to string 
			#decode and encrypt response
		end
	end
end