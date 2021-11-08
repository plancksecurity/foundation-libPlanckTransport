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
    abstract val id: Int

    /**
     * Transport uri scheme.
     *
     * Example: "ethereum" (for pdl)
     */
    abstract val uriScheme: String

    abstract fun configure() : TransportStatusCode   // To be defined, what needs to be configured.

    /**
     * Startup
     *
     * Start transport channel and subscribe to it
     *
     * @return Result with status code
     */
    abstract fun startup() : Result<TransportStatusCode>

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
     * @return Result with tatus code
     */
    abstract fun send(message: Message) : Result<TransportStatusCode>


    /**
     * Get all messages
     *
     * Get all messages from pEp distributed transport
     *
     * @return Result with list of messages or Exception
     */
    abstract fun getAllMessages(): Result<List<Message>>

    fun isOnline() = true;
    fun supportsShortMsg() = false
    fun supportsLongMsg() = true
    fun supportsLongMsgFormatted() = false
    fun nativeTextFormat() = 0                      // plain = 0, other = 0xff

    /**
     * Get event flow
     *
     * Equivalent to transport.h: notify_transport_t, instead of getting callbacks,
     * the events will be pushed to the flow
     *
     * Get Flow of Events,
     * Usage: subscribe to it to receive the events
     *
     * @return Result Flow of events received
     */
    abstract fun getEventsFlow(): Flow<Event>

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
