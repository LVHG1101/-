export interface CategoryModel {
  id: number
  name: string
  parent: CategoryModel | null
  children: CategoryModel[]
}

export interface GoodsSpec {
  name: string
  price: number
}

export interface GoodsModel {
  id: number
  name: string
  price: number
  image: string
  remain: number
  detail: string
  specs?: string
  colors?: string
  delivery?: string
  category?: CategoryModel
}

export interface UserModel {
  id?: number
  username: string
  nickname?: string
  password: string
  role?: string
}

export interface ApiResponse<T> {
  code: number
  message: string
  data?: T
  token?: string
}

// ------------------ 购物车条目 ------------------
export interface CartItemModel {
  id: number
  goodsId: number
  name: string
  price: number
  image: string
  count: number
  selected: boolean
}

// ------------------ 登录返回数据 ------------------
export interface LoginDataModel {
  username: string
  nickname: string
  token: string
  type: string
}

// ------------------ 订单状态 ------------------
export enum OrderStatus {
  PENDING_PAY = 'PENDING_PAY',
  PENDING_RECEIVE = 'PENDING_RECEIVE',
  PENDING_REVIEW = 'PENDING_REVIEW',
  COMPLETED = 'COMPLETED',
  AFTER_SALE = 'AFTER_SALE'
}

// ------------------ 订单中的商品条目 ------------------
export interface OrderGoodsItem {
  goodsId: number
  name: string
  price: number
  image: string
  count: number
}

// ------------------ 收货地址 ------------------
export interface AddressModel {
  name: string
  phone: string
  province: string
  detail: string
}

// ------------------ 评价 ------------------
export interface ReviewModel {
  rating: number
  content: string
  reviewTime: string
}

// ------------------ 订单 ------------------
export interface OrderModel {
  orderId: string
  items: OrderGoodsItem[]
  totalPrice: number
  status: OrderStatus
  createTime: string
  payMethod?: string
  address?: AddressModel
  review?: ReviewModel
  afterSaleReason?: string
}

// ------------------ 浏览足迹 ------------------
export interface FootprintModel {
  goodsId: number
  name: string
  price: number
  image: string
  visitTime: string
}

// ------------------ 服务项目 ------------------
export interface ServiceItemModel {
  id: number
  code: string
  name: string
  icon: string
  description: string
  price: number
  enabled: boolean
}

// ------------------ 服务预约订单 ------------------
export interface ServiceOrderModel {
  id: number
  serviceId: number
  serviceCode: string
  serviceName: string
  serviceIcon: string
  contactName: string
  contactPhone: string
  address: string
  appointmentTime: string
  remark: string
  status: string
  createTime: string
}

// ------------------ 商品分类（二手交易） ------------------
export interface CategoryItemModel {
  id: number
  code: string
  name: string
  icon: string
}

// ------------------ 商品（二手交易） ------------------
export interface GoodsItemModel {
  id: number
  name: string
  price: number
  image: string
  quality: string
  categoryId: number
  description?: string
  // 以下由后端附带，用于展示「低信誉卖家」标识
  userId?: number
  sellerName?: string
  sellerCredit?: number
  lowCredit?: boolean
}

// ------------------ 后端订单 ------------------
export interface TradeOrderModel {
  id: number
  orderNo: string
  totalPrice: number
  status: string
  payMethod: string
  createTime: string
  items: OrderGoodsItem[]
}

// ------------------ 售后申请 ------------------
export interface AfterSaleModel {
  id: number
  orderId: number
  orderNo: string
  totalPrice: number
  userId: number
  username: string
  reason: string
  status: string
  previousStatus: string
  applyTime: string
  handleTime: string
  adminRemark: string
}

// ------------------ 管理端预约单（含下单用户） ------------------
export interface AdminServiceOrderModel {
  id: number
  userId: number
  serviceId: number
  serviceCode: string
  serviceName: string
  serviceIcon: string
  contactName: string
  contactPhone: string
  address: string
  appointmentTime: string
  remark: string
  status: string
  createTime: string
}
