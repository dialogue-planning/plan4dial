(define
    (domain order-pizza)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (have_order)
        (maybe-have_order)
        (order_available)
        (have_start_location)
        (maybe-have_start_location)
        (have_end_location)
        (maybe-have_end_location)
        (have_payment_method)
        (maybe-have_payment_method)
        (have_card_number)
        (maybe-have_card_number)
        (goal)
        (can-do_ask-location)
        (can-do_end)
        (can-do_clarify__ask-location)
    )
    (:action ask-location
        :parameters()
        :precondition
            (and
                (not (have_start_location))
                (not (maybe-have_start_location))
                (not (have_end_location))
                (not (maybe-have_end_location))
                (can-do_ask-location)
            )
        :effect
            (labeled-oneof validate-location
                (outcome valid
                    (and
                        (have_start_location)
                        (not (maybe-have_start_location))
                        (have_end_location)
                        (not (maybe-have_end_location))
                    )
                )
                (outcome unclear_both
                    (and
                        (not (have_start_location))
                        (maybe-have_start_location)
                        (not (have_end_location))
                        (maybe-have_end_location)
                    )
                )
            )
    )
    (:action end
        :parameters()
        :precondition
            (and
                (have_start_location)
                (not (maybe-have_start_location))
                (have_end_location)
                (not (maybe-have_end_location))
                (can-do_end)
            )
        :effect
            (labeled-oneof complete
                (outcome done
                    (and
                        (goal)
                    )
                )
            )
    )
    (:action clarify__ask-location
        :parameters()
        :precondition
            (and
                (not (have_start_location))
                (maybe-have_start_location)
                (not (have_end_location))
                (maybe-have_end_location)
                (can-do_clarify__ask-location)
            )
        :effect
            (labeled-oneof yes-no
                (outcome confirm
                    (and
                        (have_start_location)
                        (not (maybe-have_start_location))
                        (have_end_location)
                        (not (maybe-have_end_location))
                    )
                )
                (outcome deny
                    (and
                        (not (have_start_location))
                        (not (maybe-have_start_location))
                        (not (have_end_location))
                        (not (maybe-have_end_location))
                    )
                )
            )
    )
)