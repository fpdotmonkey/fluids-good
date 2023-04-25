classdef WorkstationServer
        
        properties (Access = private)
                ip_address string
                port int32
                server
        end


        methods
                function self = WorkstationServer(ip_address, port)
                        arguments
                                ip_address string
                                port int32 = 8080
                        end

                        self.server = tcpserver(ip_address, port);

                        self.ip_address = self.server.ServerAddress;
                        self.port = self.server.ServerPort;

                        fprintf( ...
                                "server launched at %s:%i", ...
                                self.ip_address, ...
                                self.port ...
                        );

                        self.server.ConnectionChangedFcn = ...
                                @WorkstationServer.on_connection_changed;
                        self.server.ErrorOccurredFcn = ...
                                @WorkstationServer.on_error_occured;
                        configureCallback( ...
                                self.server, ...
                                "terminator", ...
                                @WorkstationServer.on_bytes_available ...
                        );
                end

                function delete(self)
                        fprintf( ...
                                "closing the server at %s:%i\n", ...
                                self.ip_address, ...
                                self.port ...
                        );
                        delete(self.server);
                end
        end

        methods (Static)
                function on_connection_changed(source, ~)
                        if source.Connected
                                fprintf( ...
                                        "new connection from %s:%i\n", ...
                                        source.ClientAddress, ...
                                        source.ClientPort ...
                                );
                        else
                                fprintf("a connection was lost\n");
                        end
                end

                function on_bytes_available(server, ~)
                        data = readline(server);
                        disp(data);
                        write(server, "HTTP/1.1 200 OK\r\n\r\n");
                end

                function on_error_occured(varargin)
                        disp("an error occured");
                        for arg = varargin
                                disp(arg);
                        end
                        disp(varargin);
                end
        end 
end

