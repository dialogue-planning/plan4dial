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
                        (not (conflict))
                        (know__conflict)
                        (not (have_allergy))
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
                (have_allergy)
                (not (force-statement))
                (know__have_allergy)
            )
        :effect
            (labeled-oneof set-allergy
                (outcome update_allergy
                    (and
                        (know__food_restriction)
                        (not (forcing__get-allergy))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (not (forcing__get-allergy))
                        (have-message)
                    )
                )
            )
    )
    (:action check-conflicts
        :parameters()
        :precondition
            (and
                (have_allergy)
                (know__food_restriction)
                (know__cuisine)
                (not (forcing__get-allergy))
                (not (force-statement))
                (not (maybe-know__cuisine))
                (not (know__conflict))
                (know__have_allergy)
            )
        :effect
            (labeled-oneof check-conflicts
                (outcome restriction-dessert
                    (and
                        (know__conflict)
                        (conflict)
                    )
                )
                (outcome restriction-mexican
                    (and
                        (know__conflict)
                        (conflict)
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
                (know__conflict)
                (not (force-statement))
                (conflict)
            )
        :effect
            (labeled-oneof reset
                (outcome reset-values
                    (and
                        (not (know__have_allergy))
                        (force-statement)
                        (not (maybe-know__cuisine))
                        (not (know__conflict))
                        (have-message)
                        (not (know__cuisine))
                        (not (know__food_restriction))
                    )
                )
            )
    )
    (:action set-restaurant
        :parameters()
        :precondition
            (and
                (not (know__restaurant))
                (know__cuisine)
                (not (forcing__get-allergy))
                (not (force-statement))
                (not (maybe-know__cuisine))
                (not (conflict))
                (know__conflict)
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
                (not (forcing__get-allergy))
                (know__outing_type)
                (not (maybe-know__outing_type))
                (not (force-statement))
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
                (not (forcing__get-allergy))
                (not (force-statement))
                (know__outing)
            )
        :effect
            (labeled-oneof finish
                (outcome finish
                    (and
                        (know__goal)
                        (goal)
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
                (not (forcing__get-allergy))
                (not (force-statement))
                (not (know__cuisine))
                (not (maybe-know__cuisine))
            )
        :effect
            (labeled-oneof validate-slot-fill
                (outcome cuisine_found
                    (and
                        (force-statement)
                        (know__cuisine)
                        (not (maybe-know__cuisine))
                        (have-message)
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
                (not (forcing__get-allergy))
                (not (force-statement))
                (not (know__cuisine))
                (maybe-know__cuisine)
            )
        :effect
            (labeled-oneof validate-clarification
                (outcome confirm
                    (and
                        (know__cuisine)
                        (not (maybe-know__cuisine))
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
                (not (forcing__get-allergy))
                (not (maybe-know__outing_type))
                (not (force-statement))
                (not (know__outing_type))
                (not (know__budget))
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
                        (allow_single_slot_outing_type)
                        (have-message)
                        (know__budget)
                    )
                )
                (outcome outing_type_found
                    (and
                        (know__outing_type)
                        (allow_single_slot_budget)
                        (force-statement)
                        (not (maybe-know__outing_type))
                        (have-message)
                    )
                )
                (outcome outing_type_maybe-found
                    (and
                        (maybe-know__outing_type)
                        (not (know__outing_type))
                        (allow_single_slot_budget)
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
                (not (forcing__get-allergy))
                (not (maybe-know__outing_type))
                (not (force-statement))
                (not (know__outing_type))
                (allow_single_slot_outing_type)
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
                        (maybe-know__outing_type)
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
    (:action single_slot__budget
        :parameters()
        :precondition
            (and
                (not (know__budget))
                (not (force-statement))
                (not (forcing__get-allergy))
                (allow_single_slot_budget)
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
                (maybe-know__outing_type)
                (not (forcing__get-allergy))
                (not (know__outing_type))
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