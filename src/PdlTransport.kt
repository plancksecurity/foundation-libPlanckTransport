package foundation.pEp

import foundation.pEp.jniadapter.Message

/**
 * # pEp distributed ledger transport interface
 */
abstract class PdlTransport {
    val id = 0x03
    val uriScheme = "etherum"

    abstract fun configure() : TransportStatusCode   // To be defined, what needs to be configured.
    
    /**
     * Startup
     * 
     * Start the PDL broadcast channel and subscribe to it
     * 
     * @return Status code
     */
    abstract fun startup() : TransportStatusCode
    
    /**
     * Shutdown
     * 
     * Stop the PDL broadcast channel and unsubscribe from it
     *
     * @return Status code
     */
    abstract fun shutdown() : TransportStatusCode

    /**
     * Send
     * 
     * Send the message to the ledger 
     *
     * @return Status code
     */
    abstract fun send(message: Message) : TransportStatusCode

    /**
     * Receive Next
     * 
     * Receive next message from the broadcast/ledger
     *
     * @return Pair where first is the Result containing the message received or the exception produced and second is the TransportStatusCode
     */
    abstract fun receiveNext(): Result<Pair<Message, TransportStatusCode>>

    fun isOnline() = true;
    fun supportsShortMsg() = false
    fun supportsLongMsg() = true
    fun supportsLongMsgFormatted() = false
    fun nativeTextFormat() = 0                      // plain = 0, other = 0xff

    /**
     * Notify
     *
     * This is called when a new event happens, it includes de event and the status code of that event,
     */
    fun notify(event: Event, status: TransportStatusCode) = event.post(status)

}

sealed interface Event {
    fun post(status: Int)
}

data class StatusChanged (
    val newStatus: TransportStatusCode
) : Event {
    override fun post(status: Int) {
        TODO("Not yet implemented")
    }
}
 class OnSent (                             // Data class to notify message sent
    val messageId: String,
    val address: String,
    val result: Result<Message>                 // Result is the sent message on success or an Exception on failure
) : Event {
    override fun post(status: Int) {
        TODO("Not yet implemented")
    }
}


interface OnReceive : Event {                    // Notify message received to call receiveNext
}
