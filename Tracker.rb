class Tracker
  
  def initialize(*argv, &block)
   # Trackers we were able to connect to successfully.
    @online_trackers = []
    
    # Trackers that timed out or refused connection.
    @offline_trackers = []
    
    # Set up .torrent file information for GET requests
    info = @torrent_file.to_h['info'].bencode
    
    # This is what will be passed for the info_hash GET parameter.
    @info_hash = URI.encode Digest::SHA1.digest(info).force_encoding('binary')
    
    # This is what will be passed for the peer_id GET parameter.
    @peer_id = generate_peer_id
    
    # Set up hash of tracker info for the torrent (from announce and announce-list).
    @trackers = []
    case argv
      when match( address )
       tracker_from_address( argv[0] )
      when match( address, String )
       track_from_given_address( argv[0], argv[1])
    else
      raise ArgumentError, argv.inspect
    end
  end
    
  def tracker_from_address( address )
     
  end

  def tracker_from_default_port( address )
    
  end
  
  # Establish connections to the trackers .
  def establish_connection index
    success = false
    if @trackers[index][:scheme] == 'http'
      begin
        timeout(@options[:tracker_timeout]) do
          @online_trackers << {:tracker => @trackers[index],
            :connection => Net::HTTP.start(@trackers[index][:host], @trackers[index][:port])}
          success = true
        end
      # Connection refused or timed out or whatever.
      rescue => error
        @offline_trackers << {:tracker => @trackers[index], :error => error, :failed => 1}
      end
    end
    success
  end
  def tracker_from_given_address( address, version)
    @address = address
    @torrents = ConcurrentHashMap.new()
    @connection = SocketConnection.new( 
                    TrackerService.new( version, @torrents ) )
  end

  def getAnnouceUrl
    
  end

  class Pattern
    def intialize( template )
      @template = template
    end

    def === ( objects )
      return false unless @template.size == objects.size
      @template.each_with_index do |pat, idx|
        return false unless pat ===(objects[idx])
      end
      return true
    end
  end
    
  def match( *template )
    Pattern.new( template )
  end
end
  
  
