(define
    (domain day-planner)
    (:requirements :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (know__cuisine)
        (maybe-know__cuisine)
        (know__restaurant)
        (know__have_allergy)
        (have_allergy)
        (know__food_restriction)
        (know__conflict)
        (conflict)
        (know__budget)
        (know__outing_type)
        (maybe-know__outing_type)
        (know__outing)
        (know__goal)
        (goal)
        (have-message)
        (force-statement)
        (allow_single_slot_outing_type)
        (allow_single_slot_budget)
        (forcing__get-allergy)
    )
    (:action get-have-allergy
        :parameters()
        :precondition
            (and
                (not (know__have_allergy))
                (not (force-statement))
                (not (forcing__get-allergy))
            )
        :effect
            (labeled-oneof set-allergy
                (outcome indicate_allergy
                    (and
                        (have_allergy)
                        (forcing__get-allergy)
                        (know__have_allergy)
                    )
                )
                (outcome indicate_no_allergy
                    (and
                        (not (have_allergy))
                        (not (conflict))
                        (know__conflict)
                        (know__have_allergy)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action get-allergy
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (have_allergy)
                (know__have_allergy)
            )
        :effect
            (labeled-oneof set-allergy
                (outcome update_allergy
                    (and
                        (not (forcing__get-allergy))
                        (know__food_restriction)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                        (not (forcing__get-allergy))
                    )
                )
            )
    )
    (:action check-conflicts
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__conflict))
                (not (forcing__get-allergy))
                (not (maybe-know__cuisine))
                (have_allergy)
                (know__cuisine)
                (know__food_restriction)
                (know__have_allergy)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome restriction-dessert
                    (and
                        (conflict)
                        (know__conflict)
                    )
                )
                (outcome restriction-mexican
                    (and
                        (conflict)
                        (know__conflict)
                    )
                )
                (outcome no-restriction-1
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
                (outcome no-restriction-2
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
                (outcome no-restriction-3
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
                (outcome no-restriction-4
                    (and
                        (not (conflict))
                        (know__conflict)
                    )
                )
            )
    )
    (:action reset-preferences
        :parameters()
        :precondition
            (and
                (not (forcing__get-allergy))
                (not (force-statement))
                (conflict)
                (know__conflict)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-values
                    (and
                        (not (know__have_allergy))
                        (not (know__food_restriction))
                        (have-message)
                        (not (know__conflict))
                        (not (know__cuisine))
                        (not (maybe-know__cuisine))
                        (force-statement)
                    )
                )
            )
    )
    (:action set-restaurant
        :parameters()
        :precondition
            (and
                (not (conflict))
                (know__conflict)
                (not (force-statement))
                (not (forcing__get-allergy))
                (not (maybe-know__cuisine))
                (know__cuisine)
                (not (know__restaurant))
            )
        :effect
            (labeled-oneof assign_restaurant
                (outcome set-mexican
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-italian
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-chinese
                    (and
                        (know__restaurant)
                    )
                )
                (outcome set-dessert
                    (and
                        (know__restaurant)
                    )
                )
            )
    )
    (:action set-outing
        :parameters()
        :precondition
            (and
                (not (maybe-know__outing_type))
                (not (force-statement))
                (not (forcing__get-allergy))
                (know__outing_type)
                (know__budget)
            )
        :effect
            (labeled-oneof assign_outing
                (outcome set-club
                    (and
                        (know__outing)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (know__outing)
                (not (force-statement))
                (not (forcing__get-allergy))
                (know__restaurant)
            )
        :effect
            (labeled-oneof finish
                (outcome finish
                    (and
                        (goal)
                        (know__goal)
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (force-statement)
                (have-message)
            )
        :effect
            (labeled-oneof reset
                (outcome lock
                    (and
                        (not (force-statement))
                        (not (have-message))
                    )
                )
            )
    )
    (:action slot-fill__get-cuisine
        :parameters()
        :precondition
            (and
                (not (know__cuisine))
                (not (maybe-know__cuisine))
                (not (force-statement))
                (not (forcing__get-allergy))
            )
        :effect
            (labeled-oneof validate-slot-fill
                (outcome cuisine_found
                    (and
                        (not (maybe-know__cuisine))
                        (have-message)
                        (know__cuisine)
                        (force-statement)
                    )
                )
                (outcome cuisine_maybe-found
                    (and
                        (not (know__cuisine))
                        (maybe-know__cuisine)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action clarify__cuisine
        :parameters()
        :precondition
            (and
                (not (know__cuisine))
                (not (force-statement))
                (not (forcing__get-allergy))
                (maybe-know__cuisine)
            )
        :effect
            (labeled-oneof validate-clarification
                (outcome confirm
                    (and
                        (not (maybe-know__cuisine))
                        (know__cuisine)
                    )
                )
                (outcome deny
                    (and
                        (not (know__cuisine))
                        (not (maybe-know__cuisine))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get_outing
        :parameters()
        :precondition
            (and
                (not (maybe-know__outing_type))
                (not (know__budget))
                (not (force-statement))
                (not (forcing__get-allergy))
                (not (know__outing_type))
            )
        :effect
            (labeled-oneof validate-slot-fill
                (outcome budget_found-outing_type_found
                    (and
                        (not (maybe-know__outing_type))
                        (know__outing_type)
                        (know__budget)
                    )
                )
                (outcome budget_found-outing_type_maybe-found
                    (and
                        (maybe-know__outing_type)
                        (not (know__outing_type))
                        (know__budget)
                    )
                )
                (outcome budget_found
                    (and
                        (force-statement)
                        (have-message)
                        (allow_single_slot_outing_type)
                        (know__budget)
                    )
                )
                (outcome outing_type_found
                    (and
                        (not (maybe-know__outing_type))
                        (have-message)
                        (allow_single_slot_budget)
                        (force-statement)
                        (know__outing_type)
                    )
                )
                (outcome outing_type_maybe-found
                    (and
                        (allow_single_slot_budget)
                        (not (know__outing_type))
                        (maybe-know__outing_type)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action single_slot__outing_type
        :parameters()
        :precondition
            (and
                (not (maybe-know__outing_type))
                (allow_single_slot_outing_type)
                (not (force-statement))
                (not (forcing__get-allergy))
                (not (know__outing_type))
            )
        :effect
            (labeled-oneof validate-slot-fill
                (outcome fill-slot
                    (and
                        (not (maybe-know__outing_type))
                        (know__outing_type)
                        (not (allow_single_slot_outing_type))
                    )
                )
                (outcome slot-unclear
                    (and
                        (not (know__outing_type))
                        (maybe-know__outing_type)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action single_slot__budget
        :parameters()
        :precondition
            (and
                (allow_single_slot_budget)
                (not (know__budget))
                (not (force-statement))
                (not (forcing__get-allergy))
            )
        :effect
            (labeled-oneof validate-slot-fill
                (outcome fill-slot
                    (and
                        (not (allow_single_slot_budget))
                        (know__budget)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action clarify__outing_type
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (forcing__get-allergy))
                (not (know__outing_type))
                (maybe-know__outing_type)
            )
        :effect
            (labeled-oneof validate-clarification
                (outcome confirm
                    (and
                        (not (maybe-know__outing_type))
                        (know__outing_type)
                    )
                )
                (outcome deny
                    (and
                        (not (maybe-know__outing_type))
                        (allow_single_slot_outing_type)
                        (not (know__outing_type))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
)