require 'action_dispatch/journey/router/utils'
require 'action_dispatch/journey/router/strexp'
require 'action_dispatch/journey/routes'
require 'action_dispatch/journey/formatter'

before = $-w
$-w = false
require 'action_dispatch/journey/parser'
$-w = before

require 'action_dispatch/journey/route'
require 'action_dispatch/journey/path/pattern'

module ActionDispatch
  module Journey # :nodoc:
    class Router # :nodoc:
      class RoutingError < ::StandardError # :nodoc:
      end

      # :nodoc:
      VERSION = '2.0.0'

      attr_accessor :routes

      def initialize(routes)
        @routes = routes
      end

      def serve(req)
        find_routes(req).each do |match, parameters, route|
          set_params  = req.path_parameters
          path_info   = req.path_info
          script_name = req.script_name

          unless route.path.anchored
            req.script_name = (script_name.to_s + match.to_s).chomp('/')
            req.path_info = match.post_match
            req.path_info = "/" + req.path_info unless req.path_info.start_with? "/"
          end

          req.path_parameters = set_params.merge parameters

          status, headers, body = route.app.serve(req)

          if 'pass' == headers['X-Cascade']
            req.script_name     = script_name
            req.path_info       = path_info
            req.path_parameters = set_params
            next
          end

          return [status, headers, body]
        end

        return [404, {'X-Cascade' => 'pass'}, ['Not Found']]
      end

      def recognize(rails_req)
        find_routes(rails_req).each do |match, parameters, route|
          unless route.path.anchored
            rails_req.script_name = match.to_s
            rails_req.path_info   = match.post_match.sub(/^([^\/])/, '/\1')
          end

          yield(route, parameters)
        end
      end

      def visualizer
        tt     = GTG::Builder.new(ast).transition_table
        groups = partitioned_routes.first.map(&:ast).group_by { |a| a.to_s }
        asts   = groups.values.map { |v| v.first }
        tt.visualizer(asts)
      end

      private

        def partitioned_routes
          routes.partitioned_routes
        end

        def ast
          routes.ast
        end

        def simulator
          routes.simulator
        end

        def custom_routes
          partitioned_routes.last
        end

        def filter_routes(path)
          return [] unless ast
          simulator.memos(path) { [] }
        end

        def find_routes req
          routes = filter_routes(req.path_info).concat custom_routes.find_all { |r|
            r.path.match(req.path_info)
          }

          routes =
            if req.request_method == "HEAD"
              match_head_routes(routes, req)
            else
              match_routes(routes, req)
            end

          routes.sort_by!(&:precedence)

          routes.map! { |r|
            match_data  = r.path.match(req.path_info)
            path_parameters = r.defaults.dup
            match_data.names.zip(match_data.captures) { |name,val|
              path_parameters[name.to_sym] = Utils.unescape_uri(val) if val
            }
            [match_data, path_parameters, r]
          }
        end

        def match_head_routes(routes, req)
          head_routes = match_routes(routes, req)

          if head_routes.empty?
            begin
              req.request_method = "GET"
              match_routes(routes, req)
            ensure
              req.request_method = "HEAD"
            end
          else
            head_routes
          end
        end

        def match_routes(routes, req)
          routes.select { |r| r.matches?(req) }
        end
    end
  end
end
