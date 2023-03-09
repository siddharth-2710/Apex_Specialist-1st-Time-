import { LightningElement } from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import { subscribe,unsubscribe,onError,setDebugFlag,isEmpEnabled } from 'lightning/empApi';
export default class Events extends LightningElement {
    result = "";
    channelName = "";
    isSubscribed = false;
    subscription;

    connectedCallback(){
        if(!isEmpEnabled)
        {
            console.log("Don't support Emp");
            return;
        }
        setDebugFlag(true);
        onError((error)=>{
            console.error(error);
        })
    }

    get subscriptionButtonLabel(){
        return this.isSubscribed ? "Unsubscribe" : "Subscribe";
    }

    handleChannelName({target})
    {
        this.channelName = target.value;
    }

    handleSubscription(){
        if(!this.channelName)
        return;
        if(!this.isSubscribed){
            this.handleSubscribe();
        }
        else{
            this.handleUnsubscribe();
        }
    }

    handleSubscribe(){
        const messageCallback = (response) => {
            this.result = JSON.stringify(response,null,4)
        }
        subscribe(this.channelName,-1,messageCallback).then(response =>{
            this.result = JSON.stringify(response,null,2);
            this.subscription = response;
            this.isSubscribed = true;
        })
    }

    handleUnsubscribe(){
        unsubscribe(this.subscription,()=>{
            this.result = "";
            this.isSubscribed = false;
        })
    }

    showToastEventMessage(title,message,variant)
    {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}