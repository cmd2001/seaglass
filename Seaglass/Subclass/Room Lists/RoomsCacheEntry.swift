//
// Seaglass, a native macOS Matrix client
// Copyright © 2018, Neil Alexander
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Cocoa
import MatrixSDK

class RoomsCacheEntry: NSObject {
    var room: MXRoom
    
    @objc dynamic var roomId: String {
        return room.roomId
    }
    @objc dynamic var roomName: String {
        var name = ""
        room.state { roomState in
            name = roomState?.name ?? ""
        }
        return name
    }
    @objc dynamic var roomAlias: String {
        var alias = ""
        room.state { roomState in
            alias = roomState?.canonicalAlias ?? ""
        }
        return alias
    }
    @objc dynamic var roomTopic: String {
        var topic = ""
        room.state { roomState in
            topic = roomState?.topic ?? ""
        }
        return topic
    }
    @objc dynamic var roomAvatar: String {
        var avatar = ""
        room.state { roomState in
            avatar = roomState?.avatar ?? ""
        }
        return avatar
    }
    @objc dynamic var roomSortWeight: Int {
        if isInvite() {
            return 0
        }
        if room.isDirect {
            return 70
        }
        if room.summary.isEncrypted || self.stateIsEncrypted {
            return 60
        }
        if self.roomName == "" {
            if self.roomTopic == "" {
                return 52
            }
            return 51
        }
        return 50
    }
    @objc dynamic var roomDisplayName: String {
        let count = members.count
        if roomName != "" {
            return roomName
        } else if roomAlias != "" {
            return roomAlias
        } else if count > 0 {
            var memberNames: String = ""
            for m in 0..<count {
                if members[m].userId == MatrixServices.inst.client?.credentials.userId {
                    continue
                }
                memberNames.append(members[m].displayname ?? (members[m].userId) ?? "?")
                if m < count-2 {
                    memberNames.append(", ")
                }
            }
            return memberNames
        }
        return ""
    }
    var members: [MXRoomMember] {
        var members: [MXRoomMember] = []
        room.state { roomState in
            members = roomState?.members.members ?? []
        }
        return members
    }

    @objc dynamic var stateIsEncrypted: Bool {
        var encrypted = false
        room.state { roomState in
            encrypted = roomState?.isEncrypted ?? false
        }
        return encrypted
    }
    
    init(_ room: MXRoom) {
        self.room = room
        super.init()
    }
    
    func topic() -> String {
        var topic = ""
        room.state { roomState in
            topic = roomState?.topic ?? ""
        }
        return topic
    }
    
    func unread() -> Bool {
        return room.summary.localUnreadEventCount > 0
    }
    
    func highlights() -> Int {
        let highlights: Int = 0
       /* if !MatrixServices.inst.eventCache.keys.contains(self.roomId) {
            return 0
        }
        let eventCache = MatrixServices.inst.eventCache[self.roomId]!
        let filtered = eventCache.filter({
            $0.type == "m.room.message" &&
            $0.content.keys.contains("msgtype") && ($0.content["msgtype"] as! String) == "m.text" &&
            $0.content.keys.contains("body") && ($0.content["body"] as! String).contains(MatrixServices.inst.session.myUser.displayname)
        })
        highlights += filtered.count */
        return highlights
    }
    
    func encrypted() -> Bool {
        return room.summary.isEncrypted || self.stateIsEncrypted
    }
    
    func isInvite() -> Bool {
        return MatrixServices.inst.session.invitedRooms().contains(where: { $0.roomId == room.roomId })
    }
}
