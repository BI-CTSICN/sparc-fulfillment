$("#modal_area").html("<%= escape_javascript(render(:partial =>'/service_calendar/calendar_management/edit_arm_form', locals: {arm: @arm, services: @services})) %>");
$(".selectpicker").selectpicker()
$("#modal_place").modal 'show'