# -*- encoding: utf-8 -*-

module Aliyun
  module OSS

    ##
    # OSS服务的客户端，用于获取bucket列表，创建/删除bucket。Object相关
    # 的操作请使用{OSS::Bucket}。
    # @example 创建Client
    #   endpoint = 'oss-cn-hangzhou.oss.aliyuncs.com'
    #   client = Client.new(
    #     :endpoint => endpoint,
    #     :access_key_id => 'access_key_id',
    #     :access_key_secret => 'access_key_secret')
    #   buckets = client.list_buckets
    #   client.create_bucket('my-bucket')
    #   client.delete_bucket('my-bucket')
    #   bucket = client.get_bucket('my-bucket')
    class Client

      include Logging

      # 构造OSS client，用于操作buckets。
      # @param opts [Hash] 构造Client时的参数选项
      # @option opts [String] :endpoint [必填]OSS服务的地址，可以是以
      #  oss.aliyuncs.com的标准域名，也可以是用户绑定的域名
      # @option opts [String] :access_key_id [可选]用户的ACCESS KEY ID，
      #  如果不填则会尝试匿名访问
      # @option opts [String] :access_key_secret [可选]用户的ACCESS
      #  KEY SECRET，如果不填则会尝试匿名访问
      # @option opts [Boolean] :cname [可选] 指定endpoint是否是用户绑
      #  定的域名
      # @example 标准endpoint
      #   oss-cn-hangzhou.aliyuncs.com
      #   oss-cn-beijing.aliyuncs.com
      # @example 用户绑定的域名
      #   my-domain.com
      #   foo.bar.com
      def initialize(opts)
        missing_args = [:endpoint] - opts.keys
        raise ClientError.new("Missing arguments: #{missing_args.join(', ')}") \
                             unless missing_args.empty?

        @config = Config.new(opts)
        @protocol = Protocol.new(@config)
      end

      # 列出当前所有的bucket
      # @param opts [Hash] 查询选项
      # @option opts [String] :prefix 如果设置，则只返回以它为前缀的bucket
      # @return [Enumerator<Bucket>] Bucket的迭代器
      def list_buckets(opts = {})
        raise ClientError.new("Cannot list buckets for a CNAME endpoint") \
                             if @config.cname
        Iterator::Buckets.new(@protocol, opts).to_enum
      end

      # 创建一个bucket
      # @param name [String] Bucket名字
      # @param opts [Hash] 创建Bucket的属性（可选）
      # @option opts [:location] [String] 指定bucket所在的区域，默认为oss-cn-hangzhou
      def create_bucket(name, opts = {})
        @protocol.create_bucket(name, opts)
      end

      # 删除一个bucket
      # @param name [String] Bucket名字
      # @note 如果要删除的Bucket不为空（包含有object），则删除会失败
      def delete_bucket(name)
        @protocol.delete_bucket(name)
      end

      # 获取一个Bucket对象，用于操作bucket中的objects。
      # @param name [String] Bucket名字
      # @return [Bucket] Bucket对象
      def get_bucket(name)
        Bucket.new({:name => name}, @protocol)
      end

    end # Client
  end # OSS
end # Aliyun
