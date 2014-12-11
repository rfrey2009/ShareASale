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

    //lazy instantiation of bubble factory object
    var bubbleFactory : JSQMessagesBubbleImageFactory = {
        return JSQMessagesBubbleImageFactory()
        }()    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Chat"
        self.senderId = currentUser.objectId as String
        self.senderDisplayName = currentUser.valueForKey(nameKey) as String

        var withUserAvatarPFFile = withUser.objectForKey(userPhotoKey).valueForKey(imageFileKey) as PFFile?
        var currentUserAvatarPFFile = currentUser.objectForKey(userPhotoKey).valueForKey(imageFileKey) as PFFile?
        
        if withUserAvatarPFFile != nil{
            withUserAvatarPFFile!.getDataInBackgroundWithBlock({ (data, error) -> Void in
                var theImage = UIImage(data: data)
                var avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(theImage, diameter: 30)
                
                self.avatars[self.withUser.objectId] = avatarImage                
            })
        }

        if currentUserAvatarPFFile != nil{
            currentUserAvatarPFFile!.getDataInBackgroundWithBlock({ (data, error) -> Void in
                var theImage = UIImage(data: data)
                var avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(theImage, diameter: 30)
                
                self.avatars[self.senderId] = avatarImage
            })
        }
        
        var queryForNewMessages = PFQuery(className: messageKey)
        queryForNewMessages.whereKey(fromUserKey, equalTo: currentUser)
        queryForNewMessages.whereKey(toUserKey, equalTo: withUser)
        queryForNewMessages.orderByAscending("createdAt")
        queryForNewMessages.findObjectsInBackgroundWithBlock { (messages, error) -> Void in
            self.messages = messages as [JSQMessage]
        }
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    //MARK: - Protocol conformation
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
        return avatars[message.valueForKey[fromUserKey].objectId]
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
        
        parseMessage.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil{
                println("Message saved in parse.")
            }else{
                println(error.localizedDescription)
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
