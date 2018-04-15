require './payment_gateway_client_helper'

PaymentGatewayClientHelper::Request.new({bank_ifsc_code: "ICIC0000001", bank_account_number: "1111111", amount: "10000.00", merchant_transaction_ref: "txn001", transaction_date: "2014-11-14", payment_gateway_merchant_reference: "merc001"}
).post_data