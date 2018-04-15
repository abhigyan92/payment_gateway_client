module PaymentGatewayClientHelper
	require 'net/http'
	require 'digest'
	require "openssl"                                                                                                                                                                                           
	require "base64"                                                                                                                                                                                            
	                                                                                                                                                                                                            
	include Base64 

	#key for encryption and decryption
	KEY = 'Q9fbkBF8au24C9wshGRW9ut8ecYpyXye5vhFLtHFdGjRg3a4HxPYRfQaKutZx5N4'

	# for converting hash to required string format
	def convert_params_to_string(hash)
		string = ""
		hash.each do |k,v|
			string + = "#{k}=#{v}|"
		end
	end

	#for converting string to hash for displaying result
	def convert_string_to_hash
	end

	#create sha1 disgest
	def create_sha_1_digest(string)
		sha = Digest::SHA1.hexdigest string
	end

	#encrypt the payload
	def aes_128_encryption(payload_with_sha)
		cipher = OpenSSL::Cipher::AES128.new(:CBC)  
		cipher.key = PaymentGatewayClientHelper::KEY                                                                                                                                                               
		cipher.encrypt
		encrypted_payload = cipher.update(payload_with_sha)
	end

	#decrypt the payload
	def aes_128_decryption(decoded_msg)
		cipher = OpenSSL::Cipher::AES128.new(:CBC)  
		cipher.key = PaymentGatewayClientHelper::KEY
		cipher.decrypt                                                                                                                                                               
		decrypted_payload = cipher.update(decoded_msg)
	end

	#for handling the request
	class Request
		def initialize(params)
			@request_hash = params
		end

		def post_data
			#request params are converted to string 
			payload = PaymentGatewayClientHelper.convert_params_to_string(@request)
			
			#sha is created and appended to payload
			payload_with_sha = payload + "hash=" + PaymentGatewayClientHelper.create_sha_1_digest(payload)
			
			#payload encrypted and decoded
			payload_to_pg = Base64.urlsafe_encode64(PaymentGatewayClientHelper.aes_128_encryption(payload_with_sha))
			
			#A post request need to made controller where response object is created
			#and display_result is called
			response_handler = PaymentGatewayClientHelper::Response.new
			response = response_handler.display_result(payload_to_pg)
			#post request to server
			#uri = URI('http://examplepg.com/new_transaction')
			#response = Net::HTTP.post_form(uri, 'msg' => payload_to_pg)
			#decrypt and decode response and display the final result
			decrypted_response = PaymentGatewayClientHelper.aes_128_decryption(Base64.urlsafe_decode64(response))
		end
	end

	#use request params to generate the response
	class Response

		def process_request(decrypted_payload)
			#it should check if request parameters are valid and then process the request
			#it should return the response as hash
			response_hash = {txn_status: “success”, amount:”10000.00”, merchant_transaction_ref:”txn001”, transaction_date:”2014-11-14”, payment_gateway_merchant_reference: “merc001”,payment_gateway_transaction_reference: “pg_txn_0001”, hash: “abdedffduedd0000009887”}

		end


		def display_result(msg)
			decrypted_payload = PaymentGatewayClientHelper.aes_128_decryption(Base64.urlsafe_decode64(msg))
			response_hash = process_request(decrypted_payload)
			#convert response to string 
			response_payload = PaymentGatewayClientHelper.convert_params_to_string(response_hash)
			response_payload_with_sha = response_payload + "hash=" + PaymentGatewayClientHelper.create_sha_1_digest(response_payload)
			#decode and encrypt response
			response_payload_to_pg = Base64.urlsafe_encode64(PaymentGatewayClientHelper.aes_128_encryption(response_payload_with_sha))
			
		end
	end
end