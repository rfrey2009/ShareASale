//
//  Chat.swift
//  ShareASale
//
//  Created by Ryan Frey on 12/10/14.
//  Copyright (c) 2014 Air Bronto. All rights reserved.
//

import UIKit
import Foundation

class Chat: JSQMessagesViewController {

    //MARK: - general keys and constants
    var withUser = PFUser()
    var currentUser = PFUser.currentUser()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var messages = [JSQMessage]()
    let nameKey = "name"
    let messageKey = "Message"
    let fromUserKey = "fromUser"
    let toUserKey = "toUser"
    let textKey = "text"
    let userPhotoKey = "UserPhoto"
    let imageFileKey = "imageFile"
    var messagePoller = NSTimer()
    var initialLoadingDone = Bool()

    //lazy instantiation of bubble factory object
    var bubbleFactory : JSQMessagesBubbleImageFactory = {
        return JSQMessagesBubbleImageFactory()
        }()    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Chat with \(withUser.valueForKey(nameKey)!)"
        self.senderId = currentUser.objectId as String
        self.senderDisplayName = currentUser.valueForKey(nameKey) as String
        
        var withUserAvatar = withUser.objectForKey(userPhotoKey) as PFObject
        var currentUserAvatar = currentUser.objectForKey(userPhotoKey) as PFObject
        currentUserAvatar.fetchIfNeeded()
        withUserAvatar.fetchIfNeeded()
            
        var withUserAvatarImage = withUserAvatar.valueForKey(imageFileKey) as PFFile
        var currentUserAvatarImage = currentUserAvatar.valueForKey(imageFileKey) as PFFile
        
        withUserAvatarImage.getDataInBackgroundWithBlock({ (data, error) -> Void in
            var theImage = UIImage(data: data)
            var avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(theImage, diameter: 30)
            
            self.avatars[self.withUser.objectId] = avatarImage                
        })

        currentUserAvatarImage.getDataInBackgroundWithBlock({ (data, error) -> Void in
            var theImage = UIImage(data: data)
            var avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(theImage, diameter: 30)
            
            self.avatars[self.senderId] = avatarImage
        })

        checkForMessages()
        self.messagePoller = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "checkForMessages", userInfo: nil, repeats: true)
        
    
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.collectionViewLayout.springinessEnabled = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidDisappear(animated: Bool) {
        messagePoller.invalidate()
    }
    //MARK: - Protocol conformation
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        var message = messages[indexPath.item]
        var outgoingBubble = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        var incomingBubble = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())

        if message.senderId == senderId{
            return outgoingBubble
        }
        return incomingBubble
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        var message = messages[indexPath.item]
        return avatars[message.senderId]
   }
    
    //MARK: - JSQMessages method overrides
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        var message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        
        messages.append(message)
        saveMessageToParse(message)
        self.finishSendingMessage()
        
    }
    
    //MARK: - helpers
    func saveMessageToParse(message: JSQMessage){
        var parseMessage = PFObject(className: messageKey)
        parseMessage.setObject(message.text, forKey: textKey)
        parseMessage.setObject(withUser, forKey: toUserKey)
        parseMessage.setObject(currentUser, forKey: fromUserKey)
        //setup permissions so just these two people can read messages
        var ACL = PFACL()
        ACL.setReadAccess(true, forUser: currentUser)
        ACL.setReadAccess(true, forUser: withUser)
        parseMessage.ACL = ACL
        parseMessage.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil{
                println("Message saved in parse.")
            }else{
                println(error.localizedDescription)
            }
        }
    }
    func checkForMessages(){
        println("checked for new messages")
        var queryForNewMessagesFromUser = PFQuery(className: messageKey)
        queryForNewMessagesFromUser.whereKey(fromUserKey, equalTo: currentUser)
        queryForNewMessagesFromUser.whereKey(toUserKey, equalTo: withUser)
        
        var queryForNewMessagesToUser = PFQuery(className: messageKey)
        queryForNewMessagesToUser.whereKey(toUserKey, equalTo: currentUser)
        queryForNewMessagesToUser.whereKey(fromUserKey, equalTo: withUser)
        
        var queryForNewMessages = PFQuery.orQueryWithSubqueries([queryForNewMessagesFromUser, queryForNewMessagesToUser])
        queryForNewMessages.includeKey(fromUserKey)
        queryForNewMessages.orderByAscending("createdAt")
        
        queryForNewMessages.findObjectsInBackgroundWithBlock { (pastMessages, error) -> Void in
            
            if pastMessages.count > self.messages.count{
                //if there's new messages and we're past the first load, play sound and empty messages array
                if self.initialLoadingDone == true {
                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    self.messages = []
                }
                //(re)build messages array
                for pastMessage in pastMessages{
                    var id = pastMessage.valueForKey(self.fromUserKey)?.objectId
                    var who = pastMessage.valueForKey(self.fromUserKey) as PFUser
                    var name = who.valueForKey(self.nameKey) as String
                    var t = pastMessage.valueForKey(self.textKey) as String
                    
                    var message = JSQMessage(senderId: id!, displayName: name, text: t)
                    self.messages.append(message)
                }
                self.initialLoadingDone = true
                self.finishReceivingMessage()
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
