package foundation.pEp

import foundation.pEp.jniadapter.Message
import foundation.pEp.jniadapter.Rating
import kotlinx.coroutines.flow.Flow

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

    abstract fun configure(): TransportStatusCode   // To be defined, what needs to be configured.

    /**
     * Startup
     *
     * Start transport channel and subscribe to it
     *
     * @return Result with status code
     */
    abstract fun startup(): Result<TransportStatusCode>

    /**
     * Shutdown
     *
     * Stop transport channel and unsubscribe/disconnect from it
     *
     * @return Status code
     */
    abstract fun shutdown(): TransportStatusCode

    /**
     * Send
     *
     * Send the message to the transport
     *
     * @return Result with tatus code
     */
    abstract fun send(message: Message): Result<TransportStatusCode>


    /**
     * Get all messages
     *
     * Get all messages from pEp distributed transport
     *
     * @return Result with list of messages or Exception
     */
    abstract fun getAllMessages(): Result<List<Message>>

    fun isOnline() = true
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

/**
 * Base Event that represents action that happened on Transport
 *
 * @property status event status code
 * @constructor Create Event
 */
sealed class Event(private val status: TransportStatusCode)

/**
 * Data class to notify status changes
 * Equivalent to transport.h: signal_statuschange_t
 *
 * @property newStatus event status code
 * @constructor Create StatusChanged Event
 */
data class StatusChanged(
    val newStatus: TransportStatusCode
) : Event(newStatus)

/**
 * Data class to notify message sent
 * Equivalent to transport.h: signal_sendto_result_t
 *
 * @property status event status code
 * @property messageId message id
 * @property address address message was sent to
 * @property rating rating of the message sent
 * @property result Result with Message sent on success or Exception on Failure
 * @constructor Create OnSent Event
 */
data class OnSent(
    val status: TransportStatusCode,
    val messageId: String,
    val address: String,
    val rating: Rating,
    val result: Result<Message>
) : Event(status)

/**
 * Data class to notify message received
 * Equivalent to transport.h: signal_incoming_message_t
 *
 * @property status event status code
 * @property message message received
 * @constructor Create OnReceive Event
 */
data class OnReceive(
    val status: TransportStatusCode,
    val message: Message
) : Event(status)