--!strict
local Registry={};local entries:{[RBXScriptConnection]:{owner:string,category:string}}={}
function Registry.Register(connection:RBXScriptConnection,owner:string,category:string):RBXScriptConnection entries[connection]={owner=owner,category=category};return connection end
function Registry.Disconnect(connection:RBXScriptConnection)if entries[connection]then entries[connection]=nil end;if connection.Connected then connection:Disconnect()end end
function Registry.DisconnectOwner(owner:string):number local n=0;for connection,data in entries do if data.owner==owner then Registry.Disconnect(connection);n+=1 end end;return n end
function Registry.GetActiveCount():number local n=0;for connection in entries do if connection.Connected then n+=1 else entries[connection]=nil end end;return n end
function Registry.GetCountsByCategory():{[string]:number}local out={};for c,d in entries do if c.Connected then out[d.category]=(out[d.category]or 0)+1 end end;return out end
function Registry.GetCountsByOwner():{[string]:number}local out={};for c,d in entries do if c.Connected then out[d.owner]=(out[d.owner]or 0)+1 end end;return out end
return Registry
