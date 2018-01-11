class BillingsController < ApplicationController
before_action :find_cart
  def pre_pay
    items = @orders.paypal_items
    total = @orders.total
    payment = Billing.init_payment(items,total)
    if payment.create
      redirect_url = payment.links.find{|v| v.method == "REDIRECT" }.href
      redirect_to redirect_url
    else
    render json:  payment.error
    end
  end

  def execute
    if Billing.execute_payment(current_user, params[:paymentId], params[:PayerID])
      redirect_to root_path, notice: "La compra se realizó con éxito!"
    else
      render plain: "No se pudo generar el cobro en PayPal"
    end
  end
private
  def find_cart
    @orders = current_user.orders.cart
  end
end
