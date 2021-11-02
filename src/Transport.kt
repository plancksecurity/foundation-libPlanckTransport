package foundation.pEp

import foundation.pEp.jniadapter.Message
import foundation.pEp.jniadapter.Rating

/**
 * # pEp distributed transport Kotlin interface
 */
abstract class Transport {
    /**
     * Transport id
     *
     * Exaple: 0x03 (for pdl)
     */
    abstract val id

    /**
     * Transport uri scheme.
     *
     * Example: "ethereum" (for pdl)
     */
    abstract val uriScheme

    abstract fun configure() : TransportStatusCode   // To be defined, what needs to be configured.

    /**
     * Startup
     *
     * Start transport channel and subscribe to it
     *
     * @return Status code
     */
    abstract fun startup() : TransportStatusCode

    /**
     * Shutdown
     *
     * Stop transport channel and unsubscribe/disconnect from it
     *
     * @return Status code
     */
    abstract fun shutdown() : TransportStatusCode

    /**
     * Send
     *
     * Send the message to the transport
     *
     * @return Status code
     */
    abstract fun send(message: Message) : TransportStatusCode

    /**
     * Receive Next
     *
     * Receive next message from transport
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
    fun post(status: TransportStatusCode)
}

data class StatusChanged (
    val newStatus: TransportStatusCode
) : Event {
    override fun post(status: TransportStatusCode) {
        TODO("Not yet implemented")
    }
}
class OnSent (                             // Data class to notify message sent
    val messageId: String,
    val address: String,
    val rating: Rating,
    val result: Result<Message>                 // Result is the sent message on success or an Exception on failure
) : Event {
    override fun post(status: TransportStatusCode) {
        TODO("Not yet implemented")
    }
}


interface OnReceive : Event {                    // Notify message received to call receiveNext
}
