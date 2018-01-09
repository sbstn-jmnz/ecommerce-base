class BillingsController < ApplicationController

  def pre_pay
    orders = current_user.orders.where(payed: false)
    total = orders.pluck("price * quantity").sum
    items = orders.map do |order|
      item = {}
      item[:name] = order.product.name
      item[:sku] = order.id.to_s
      item[:price] = order.price.to_s
      item[:currency] = 'USD'
      item[:quantity] = order.quantity
      item
    end
    payment = PayPal::SDK::REST::Payment.new({
      intent: "sale",
      payer: {
        payment_method: "paypal" },
        redirect_urls: {
          return_url: "http://localhost:3000/billings/execute",
          cancel_url: "http://localhost:3000/" },
          transactions: [{
            item_list: {
              items: items
            },
            amount: {
              total: total.to_s,
              currency: "USD" },
              description: "Compra desde E-commerce Rails." }]
              })
    if payment.create
      redirect_url = payment.links.find{|v| v.method == "REDIRECT" }.href
      redirect_to redirect_url
    else
    render json:  payment.error
    end
  end

  def execute
    paypal_payment = PayPal::SDK::REST::Payment.find(params[:paymentId])
    if paypal_payment.execute(payer_id: params[:PayerID])
      render plain: ":)"
    else
      render plain: ":("
    end
  end

end
